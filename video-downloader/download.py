"""
Video Downloader Script
-----------------------
Downloads videos/playlists from sites like Bilibili, YouTube, Vimeo, etc.
Uses yt-dlp under the hood.

Usage:
    python download.py                          # Interactive mode
    python download.py <URL>                    # Download all from URL
    python download.py <URL> --list             # List videos only
    python download.py <URL> --pick 1,3,5-10    # Download specific items
    python download.py <URL> --audio-only       # Extract audio only
"""

import subprocess
import sys
import os
import argparse
import json
import re
from pathlib import Path

DOWNLOAD_DIR = Path(__file__).parent / "downloads"

# Use 'python -m yt_dlp' to avoid PATH issues on Windows
YT_DLP_CMD = [sys.executable, "-m", "yt_dlp"]


def ensure_yt_dlp():
    try:
        subprocess.run(
            YT_DLP_CMD + ["--version"],
            capture_output=True, text=True, check=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError, ModuleNotFoundError):
        print("[*] yt-dlp not found. Installing via pip...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-U", "yt-dlp"])
        print("[+] yt-dlp installed.\n")


def check_ffmpeg():
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
        return True
    except FileNotFoundError:
        return False


def parse_pick_ranges(pick_str: str) -> set[int]:
    """Parse '1,3,5-10' into {1,3,5,6,7,8,9,10}."""
    indices = set()
    for part in pick_str.split(","):
        part = part.strip()
        if "-" in part:
            lo, hi = part.split("-", 1)
            indices.update(range(int(lo), int(hi) + 1))
        else:
            indices.add(int(part))
    return indices


def list_videos(url: str) -> list[dict]:
    """Fetch playlist/video metadata and return entries."""
    print(f"\n[*] Fetching video list from:\n    {url}\n")
    print("    (resolving titles — may take a moment for large playlists...)\n")

    result = subprocess.run(
        YT_DLP_CMD + [
            "--dump-single-json",
            "--skip-download",
            "--no-warnings",
            url,
        ],
        capture_output=True, text=True,
    )

    if result.returncode != 0:
        print(f"[!] yt-dlp error:\n{result.stderr}")
        return []

    data = json.loads(result.stdout)

    entries = data.get("entries") or [data]
    videos = []
    for i, entry in enumerate(entries, 1):
        title = entry.get("title") or entry.get("id") or "Unknown"
        duration = entry.get("duration")
        dur_str = f"{int(duration)//60}:{int(duration)%60:02d}" if duration else "?"
        vid_url = entry.get("webpage_url") or entry.get("url") or ""
        videos.append({
            "index": i,
            "title": title,
            "duration": dur_str,
            "url": vid_url,
        })

    return videos


def print_video_table(videos: list[dict]):
    if not videos:
        print("[!] No videos found.")
        return

    max_title = min(max(len(v["title"]) for v in videos), 70)
    header = f"  {'#':>4}  {'Title':<{max_title}}  {'Duration':>8}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for v in videos:
        title = v["title"][:70]
        print(f"  {v['index']:>4}  {title:<{max_title}}  {v['duration']:>8}")
    print(f"\n  Total: {len(videos)} video(s)\n")


def build_download_cmd(url: str, output_dir: Path, audio_only: bool = False,
                       pick: set[int] | None = None, quality: str = "best") -> list[str]:
    output_dir.mkdir(parents=True, exist_ok=True)
    template = str(output_dir / "%(playlist_index|)s%(playlist_index& - |)s%(title)s.%(ext)s")

    cmd = YT_DLP_CMD + [
        "--no-warnings",
        "-o", template,
        "--restrict-filenames",
        "--concurrent-fragments", "4",
    ]

    if audio_only:
        cmd += ["-x", "--audio-format", "mp3"]
    elif quality == "best":
        cmd += ["-f", "bestvideo+bestaudio/best"]
    elif quality == "720":
        cmd += ["-f", "bestvideo[height<=720]+bestaudio/best[height<=720]"]
    elif quality == "480":
        cmd += ["-f", "bestvideo[height<=480]+bestaudio/best[height<=480]"]

    if not check_ffmpeg():
        filtered = []
        skip_next = False
        for c in cmd:
            if skip_next:
                skip_next = False
                continue
            if c == "-f":
                skip_next = True
                continue
            filtered.append(c)
        cmd = filtered
        print("[!] ffmpeg not found — downloading single-stream (may be lower quality).")
        print("    Install ffmpeg for best quality merging. Run: setup.bat\n")

    if pick:
        items = ",".join(str(i) for i in sorted(pick))
        cmd += ["--playlist-items", items]

    cmd.append(url)
    return cmd


def download(url: str, output_dir: Path, audio_only: bool = False,
             pick: set[int] | None = None, quality: str = "best"):
    cmd = build_download_cmd(url, output_dir, audio_only, pick, quality)
    print(f"[*] Downloading to: {output_dir}\n")
    print(f"    Command: {' '.join(cmd)}\n")
    subprocess.run(cmd)
    print(f"\n[+] Done! Files saved in: {output_dir}")


def interactive_mode():
    print("=" * 60)
    print("        VIDEO DOWNLOADER  (yt-dlp wrapper)")
    print("=" * 60)
    print("\nSupports: YouTube, Bilibili, Vimeo, Dailymotion,")
    print("          Twitter/X, Instagram, and 1000+ more sites.\n")

    url = input("Paste video/playlist URL: ").strip()
    if not url:
        print("[!] No URL provided.")
        return

    safe_name = re.sub(r'[^\w\-]', '_', url.split("//")[-1][:50])
    output_dir = DOWNLOAD_DIR / safe_name

    print("\nOptions:")
    print("  1. List videos first (recommended for playlists)")
    print("  2. Download ALL videos")
    print("  3. Download audio only (MP3)")
    print("  4. Enter specific video numbers to download")

    choice = input("\nChoice [1-4] (default: 2): ").strip() or "2"

    if choice == "1":
        videos = list_videos(url)
        print_video_table(videos)
        if not videos:
            return

        sub = input("Enter numbers to download (e.g. 1,3,5-10) or 'all': ").strip()
        if sub.lower() == "all" or sub == "":
            download(url, output_dir)
        else:
            pick = parse_pick_ranges(sub)
            download(url, output_dir, pick=pick)

    elif choice == "2":
        quality = input("Quality? [best/720/480] (default: best): ").strip() or "best"
        download(url, output_dir, quality=quality)

    elif choice == "3":
        download(url, output_dir, audio_only=True)

    elif choice == "4":
        nums = input("Enter video numbers (e.g. 1,3,5-10): ").strip()
        pick = parse_pick_ranges(nums)
        download(url, output_dir, pick=pick)

    else:
        print("[!] Invalid choice.")


def main():
    ensure_yt_dlp()

    parser = argparse.ArgumentParser(
        description="Download videos from Bilibili, YouTube, and 1000+ sites."
    )
    parser.add_argument("url", nargs="?", help="Video or playlist URL")
    parser.add_argument("--list", "-l", action="store_true",
                        help="List videos without downloading")
    parser.add_argument("--pick", "-p", type=str, default=None,
                        help="Download specific items, e.g. 1,3,5-10")
    parser.add_argument("--audio-only", "-a", action="store_true",
                        help="Extract audio as MP3")
    parser.add_argument("--quality", "-q", choices=["best", "720", "480"],
                        default="best", help="Video quality (default: best)")
    parser.add_argument("--output", "-o", type=str, default=None,
                        help="Output directory name (inside downloads/)")

    args = parser.parse_args()

    if not args.url:
        interactive_mode()
        return

    safe_name = args.output or re.sub(r'[^\w\-]', '_', args.url.split("//")[-1][:50])
    output_dir = DOWNLOAD_DIR / safe_name

    if args.list:
        videos = list_videos(args.url)
        print_video_table(videos)
        return

    pick = parse_pick_ranges(args.pick) if args.pick else None
    download(args.url, output_dir, audio_only=args.audio_only,
             pick=pick, quality=args.quality)


if __name__ == "__main__":
    main()
