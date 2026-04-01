import { Resvg } from "npm:@resvg/resvg-js";
import { ensureDir } from "https://deno.land/std/fs/mod.ts";
import { join } from "https://deno.land/std/path/mod.ts";

const iconPath = "/home/avadhut/Downloads/vscode-material-icon-theme-main/icons";
const outputPath = "/home/avadhut/Downloads/vscode-material-icon-theme-main/icons/PNG_icons/";

async function convertSvgToPng(iconName: string): Promise<void> {
    const svgFilePath = join(iconPath, iconName);
    const pngFileName = iconName.replace('.svg', '.png');
    const pngFilePath = join(outputPath, pngFileName);

    try {
        // Read the SVG file
        const svgContent = await Deno.readTextFile(svgFilePath);

        // Convert SVG to PNG
        const resvg = new Resvg(svgContent, {
            fitTo: {
                mode: 'width',
                value: 256
            }
        });

        const pngData = resvg.render();
        const pngBuffer = pngData.asPng();

        // Ensure output directory exists
        await ensureDir(outputPath);

        // Write PNG data to file
        await Deno.writeFile(pngFilePath, pngBuffer);

        console.log(`Converted ${iconName} to PNG: ${pngFilePath}`);
    } catch (error) {
        console.error(`Error converting ${ iconName }:`, error);
    }
}

// Usage
const iconName = prompt("Enter the name of the SVG icon (e.g., tilt-filter.svg): ");
if (iconName) {
    await convertSvgToPng(iconName);
} else {
    console.log("No icon name provided.");
}