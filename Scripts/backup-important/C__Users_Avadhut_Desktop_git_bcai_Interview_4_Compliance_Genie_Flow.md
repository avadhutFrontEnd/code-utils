# Compliance Genie - Complete Flow Documentation

## Overview

**Compliance Genie** (also known as "AI Ad Agent") is an AI-powered brand compliance auditing tool that analyzes ad creatives against brand guidelines, compliance documents, and legal requirements. Users upload ad images and brand guidelines, and the system provides detailed compliance analysis with actionable recommendations.

**Route:** `/create/agent`

**Purpose:** Instantly audit ads for brand compliance, identify violations, and receive recommendations for improvement.

**Key Features:**
- Upload ad creatives (images, campaigns)
- Upload brand guidelines or compliance documents
- AI-powered compliance analysis
- Detailed validation results with scores
- Visual editor for reviewing violations
- Real-time analyzing state with progress indicator
- Download PDF reports
- Search and filter compliance checks
- Expandable compliance check details
- Chatbot interface for interactive auditing
- Client name autocomplete with suggestions

---

## 1. Landing on Compliance Genie Page (`/create/agent`)

### Navigation to Compliance Genie

**Access Points:**
1. **From `/create` page:**
   - Click "AI Ad Agent" icon in the circular tool buttons
   - Or click "Compliance Genie" in the left sidebar navigation

2. **Direct URL:**
   - Navigate to: `https://app.pixelplusai.com/create/agent`

### Initial UI State

When a user first lands on the page, they see:

**Header Section:**
- **Title:** "AI Ad Agent – Instantly Audit Your Ads with AI"
- **Subtitle:** "Upload your ad creatives, campaigns, or images and let the AI Ad Agent analyze them against your brand kit, compliance guidelines, or legal requirements."

**Main Content Area:**
Two-column layout with form fields and upload areas:

**Left Column:**
1. **Campaign Name Input:**
   - Label: "Campaign Name"
   - Placeholder: "Enter a Campaign Name"
   - Type: Text input
   - Required field
   - Styling: Border, rounded corners, focus ring

2. **Upload Ad Creative Section:**
   - Label: "Upload Ad creative, Campaign or Image to Audit"
   - Large dashed-border upload box
   - Drag and drop support
   - Click to upload button
   - Accepted formats: PNG, SVG, or JPG
   - Visual feedback:
     - Default: White background, gray border
     - Drag over: Blue border, blue background
     - File uploaded: Green border, green background
   - File preview with remove option

**Right Column:**
1. **Client Name Input:**
   - Label: "Client Name"
   - Placeholder: "Enter your Client Name"
   - Type: Text input with autocomplete
   - Required field
   - **Autocomplete Features:**
     - Fetches clients from API on component mount
     - Shows suggestions dropdown when typing
     - Filters by company name or approver name
     - Displays company name and email in suggestions
     - Click to select from suggestions
     - Loading indicator while fetching

2. **Upload Brand Guidelines Section:**
   - Label: "Upload Brand Guidelines, Compliance document"
   - Large dashed-border upload box
   - Drag and drop support
   - Click to upload button
   - Accepted formats: PNG, SVG, JPG, PDF, DOC, DOCX
   - Multiple file upload support
   - Visual feedback (same as ad upload)
   - File list with individual remove buttons

**OR Divider:**
- Horizontal line with "OR" text in center
- Separates upload section from text input

**Additional Rules Section:**
- Label: "Additional rules (If they conflict with brand guidelines audit results are unpredictable)"
- Large textarea
- Placeholder: "Enter description ..."
- Optional field
- Used when brand guidelines files are not uploaded

**Action Buttons (Bottom Right):**
- **Cancel Button:**
  - Gray border, white background
  - Clears all form fields
  - Resets errors
  - Closes client suggestions

- **Start Audit Button:**
  - Blue background (#blue-600)
  - White text
  - Triggers validation and audit process
  - Disabled if validation fails

**Error Display:**
- Red error box appears at top if validation fails
- Lists all validation errors
- Dismissible

---

## 2. Form Validation

### Validation Rules

**Required Fields:**
1. **Campaign Name:**
   - Must not be empty
   - Must be trimmed (no whitespace only)

2. **Client Name:**
   - Must not be empty
   - Must be trimmed

3. **Ad File:**
   - Must be uploaded
   - Must be an image file (JPG, PNG, GIF, or WebP)
   - Single file only

4. **Brand Guidelines:**
   - Either brand kit files OR branding rules text must be provided
   - If files uploaded: Must be valid format (PDF, DOC, DOCX, or images)
   - If text provided: Must not be empty

### Validation Flow

```
User clicks "Start Audit"
  ↓
validateForm() called
  ↓
Check Campaign Name → If empty: Add error
  ↓
Check Client Name → If empty: Add error
  ↓
Check Ad File → If missing: Add error
  ↓
Check Brand Guidelines:
  - If no files AND no text → Add error
  - If files exist → Validate file types
  ↓
If errors found:
  - Display error box
  - Prevent form submission
  ↓
If no errors:
  - Proceed to audit
```

---

## 3. Starting the Audit

### User Flow

```
User fills form and clicks "Start Audit"
  ↓
Form validation passes
  ↓
handleAuditClick() called
  ↓
onNextStep() callback triggered
  ↓
handleUploadComplete() in BrandAuditInterface
  ↓
State updates:
  - currentStep: 'upload' → 'audit'
  - uploadData: Set with form data
  - isLoading: true
  ↓
callValidationAPI() called
  ↓
UI shows analyzing state:
  - Left: Uploaded image displayed
  - Right: "Analyzing Your Ad" with spinner
  - "Analyzing..." button in header
  ↓
API Request: POST /api/v1/chatbot/validate-brand-guidelines
  ↓
API processing (10-30 seconds typically)
  ↓
Response received and processed
  ↓
State updates:
  - isLoading: false
  - validationResults: Set with API response
  ↓
UI switches to audit results view:
  - Left: Brand Compliance Analysis with summary
  - Right: Detailed Validation Results
  - Download PDF button appears
```

### API Call Details

**Endpoint:** `POST /api/v1/chatbot/validate-brand-guidelines`

**Request Format:**
- Content-Type: `multipart/form-data`
- Authentication: Bearer token required

**Form Data:**
```
adImage: File (required)
  - Image file (JPG, PNG, GIF, WebP)
  
brandBook: File (required if no branding rules)
  - PDF, DOC, DOCX, or image file
  - OR text file created from branding rules textarea
```

**Request Headers:**
```json
{
  "Authorization": "Bearer <accessToken>",
  "Content-Type": "multipart/form-data"
}
```

**Response Structure:**
```json
{
  "success": true,
  "validationResults": [
    {
      "elementType": "Primary Typography",
      "status": "compliant" | "non-compliant" | "needs_review",
      "score": 76,
      "message": "Brand guidelines specify primary font: Standard font. Ad analysis detected fonts: Not detected. The ad aligns well with brand font specifications.",
      "recommendations": [
        "Ensure font consistency across all text elements",
        "Use brand-approved font weights"
      ]
    },
    {
      "elementType": "Text Hierarchy",
      "status": "compliant",
      "score": 80,
      "message": "Text hierarchy in the ad follows brand guidelines effectively.",
      "recommendations": []
    }
  ],
  "summary": {
    "totalElements": 17,
    "compliantElements": 11,
    "nonCompliantElements": 6,
    "overallComplianceScore": 65,
    "overallStatus": "needs_review"
  }
}
```

**Status Values:**
- `"compliant"`: Element meets all requirements (green)
- `"needs_review"`: Element has minor issues (yellow)
- `"non-compliant"`: Element violates guidelines (red)

**Overall Status Values:**
- `"compliant"`: 80-100% score
- `"needs_review"`: 50-79% score
- `"non_compliant"`: 0-49% score

**Error Response:**
```json
{
  "success": false,
  "message": "Failed to validate brand guidelines"
}
```

---

## 4. Analyzing State (Loading)

### UI During Analysis

After clicking "Start Audit", the UI transitions to the analyzing state:

**Left Side: Brand Compliance Editor**
- **Header Section:**
  - "< Back" button (returns to upload form)
  - Campaign name displayed (e.g., "Summer Launch 2026")
  - Client name displayed below campaign (e.g., "EcoStyle")
  - **"Analyzing..." button** (gray background with spinning loader icon)
    - Position: Top right
    - Shows loading state during API processing

- **Uploaded Ad Image Section:**
  - Title: "Uploaded Ad Image"
  - Large gray box containing the uploaded ad preview
  - Image displayed at full size
  - No markers or overlays during analysis

**Right Side: Validation Results Sidebar**
- **Header:**
  - "Validation Results" title with document icon
  - Subtitle: "Brand Guidelines Analysis"

- **Loading State:**
  - Large animated blue spinning circle (centered)
  - Text: "Analyzing Your Ad"
  - Subtext: "Checking against brand guidelines..."
  - No results displayed yet

**State Duration:**
- Typically 10-30 seconds depending on:
  - File sizes
  - API processing time
  - Network speed

---

## 5. Audit Results View

### UI Layout

After audit completes, the UI displays results in a split-screen layout:

**Left Side: Brand Compliance Editor**
- **Header Section:**
  - "< Back" button (returns to upload form)
  - Campaign name (e.g., "Summer Launch 2026")
  - Client name below campaign (e.g., "EcoStyle")
  - **"Download PDF" button** (blue background, download icon)
    - Position: Top right
    - Exports audit results as PDF

- **Brand Compliance Analysis Section:**
  - **Title:** "Brand Compliance Analysis"
  - **Description:** "Comprehensive review of your ad against brand guidelines."
  
  - **Overall Compliance Score Card:**
    - Large card displaying overall score (e.g., "65%")
    - Status button below score (e.g., "Needs Review" - yellow/blue)
    - Prominent display with visual emphasis
  
  - **Summary Cards (3 cards in row):**
    - **"Total Elements"** card:
      - Number displayed (e.g., "17")
      - Label: "Total Elements"
      - White background, border
    
    - **"Compliant" card:**
      - Number in green (e.g., "11")
      - Label: "Compliant"
      - Green background or green text
    
    - **"Needs Review" or "Issues Found" card:**
      - Number in yellow/red (e.g., "6")
      - Label: "Needs Review" or "Issues Found"
      - Yellow/red background or text

  - **Key Findings Section:**
    - Title: "Key Findings"
    - List of top 5 compliance checks
    - Each finding shows:
      - **Status dot:** Green (compliant) or Yellow (needs review)
      - **Element name:** (e.g., "Primary Typography")
      - **Score:** Percentage (e.g., "76%")
      - **Description:** Assessment message (truncated to 2 lines)

- **Uploaded Ad Image Section:**
  - Title: "Uploaded Ad Image"
  - Full-size preview of uploaded ad
  - No interactive markers (in this view)

**Right Side: Single Template Sidebar (Validation Results)**

- **Header:**
  - "Validation Results" title with document icon
  - Subtitle: "Brand Guidelines Analysis"

- **Overall Compliance Score Section:**
  - **Score Display:**
    - Large percentage (e.g., "65%")
    - Color-coded based on score:
      - Green: 80-100%
      - Yellow: 50-79%
      - Red: 0-49%
    - Small upward trend icon (if applicable)
  
  - **Status Badge:**
    - Button with status text (e.g., "needs review")
    - Color-coded border and background
    - Position: Next to score

- **Summary Cards (3 cards in grid):**
  - **"Total Elements"** card:
    - Large number (e.g., "17")
    - Label: "Total Elements"
    - White background, border
  
  - **"Compliant" card:**
    - Large number in green (e.g., "11")
    - Label: "Compliant"
    - White background, green text
  
  - **"Issues Found" card:**
    - Large number in red (e.g., "6")
    - Label: "Issues Found"
    - White background, red text

- **Search and Filter Bar:**
  - Search input with magnifying glass icon
  - Placeholder: "Search validation results..."
  - Filter icon on the right
  - Allows filtering compliance checks

- **Compliance Checks List (Scrollable):**
  - Expandable list of all compliance checks
  - Each check item shows:
    
    **Header Row:**
    - **Status Icon:**
      - Green checkmark (✓): Compliant
      - Red X (✗): Non-compliant
      - Yellow triangle (⚠): Warning/Needs Review
    
    - **Element Name:** (e.g., "Primary Typography")
      - Capitalized and formatted
      - Clickable to expand
    
    - **Score:** Percentage (e.g., "76%")
      - Displayed prominently
    
    - **Status Tag:**
      - "compliant" (green)
      - "needs review" (yellow)
      - "non-compliant" (red)
      - Rounded badge style
    
    - **Expand/Collapse Arrow:**
      - ChevronDown/ChevronUp icon
      - Toggles detailed view
    
    **Expanded Content (when clicked):**
    - **Full Description:**
      - Complete assessment message
      - Example: "Brand guidelines specify primary font: Standard font. Ad analysis detected fonts: Not detected. The ad aligns well with brand font specifications."
    
    - **Issues List (if any):**
      - Bulleted list of specific issues
      - Red text for non-compliant items
    
    - **Recommendations:**
      - Actionable improvement suggestions
      - Bulleted list format

  - **Example Compliance Checks:**
    - Primary Typography
    - Text Hierarchy
    - Logo Placement
    - Color Compliance
    - Layout and Spacing
    - Messaging Compliance
    - Brand Voice
    - Image Quality
    - CTA Compliance
    - Legal Requirements

  - **Scrollable Area:**
    - Vertical scrollbar when content exceeds viewport
    - Smooth scrolling

- **Floating Chat Icon:**
  - Purple circular button at bottom right
  - PixelPlus AI character icon
  - Opens chatbot interface (if available)

### Brand Compliance Editor Details

**Components:**
1. **Header:**
   - Campaign name
   - Client name
   - Back button (returns to upload form)
   - Download PDF button

2. **Image Display:**
   - Uploaded ad image shown at full size
   - Gray background container
   - No validation markers in main view
   - Image preview only

3. **Analysis Summary:**
   - Overall compliance score card
   - Summary statistics cards
   - Key findings list

### Single Template Sidebar Details

**Summary Section:**
- Overall compliance score (percentage) with color coding
- Total elements analyzed
- Compliant vs non-compliant count
- Overall status badge

**Search and Filter:**
- Real-time search through compliance checks
- Filter by status (compliant, non-compliant, needs review)
- Filter by element type

**Detailed Results:**
- Expandable sections for each compliance check
- Each section shows:
  - Status icon (checkmark, X, or warning)
  - Element type name
  - Score percentage
  - Status tag (compliant/needs review/non-compliant)
  - Full assessment message (when expanded)
  - Issues list (if any)
  - Recommendations (when expanded)

**Action Buttons:**
- Download PDF (in header)
- Share results (if available)
- Start new audit (via Back button)

---

## 5. Client Name Autocomplete

### Functionality

**Data Source:**
- Fetches clients from: `GET /api/v1/clients/my-clients`
- Loads on component mount
- Cached in component state

**Autocomplete Behavior:**
1. **On Focus:**
   - If input is empty: Shows all clients
   - If input has text: Shows filtered clients

2. **On Type:**
   - Filters clients in real-time
   - Matches against:
     - Company name (starts with)
     - Approver name (starts with)
   - Case-insensitive matching
   - Shows only matching clients

3. **Suggestion Display:**
   - Dropdown below input field
   - Max height: 48 (scrollable)
   - Each suggestion shows:
     - Company name (bold)
     - Email address (smaller, gray)
   - Hover effect: Gray background
   - Click to select

4. **Selection:**
   - Fills input with company name
   - Closes dropdown
   - Clears filter

**Loading State:**
- Spinner icon shown while fetching
- Position: Right side of input

**Click Outside:**
- Closes dropdown
- Preserves input value

---

## 6. File Upload Features

### Ad Creative Upload

**Supported Formats:**
- PNG
- SVG
- JPG/JPEG
- GIF
- WebP

**Upload Methods:**
1. **Click to Upload:**
   - Click "Click to upload" link
   - Opens file picker
   - Select single file

2. **Drag and Drop:**
   - Drag file over upload area
   - Visual feedback (blue border/background)
   - Drop to upload
   - Single file only

**File Validation:**
- Checks file type on selection
- Rejects non-image files
- Shows error if invalid

**File Display:**
- Green success box when uploaded
- Shows file name
- Remove button to clear

### Brand Guidelines Upload

**Supported Formats:**
- PNG, SVG, JPG (images)
- PDF (documents)
- DOC, DOCX (Word documents)

**Upload Methods:**
1. **Click to Upload:**
   - Click "Click to upload" link
   - Opens file picker
   - Multiple file selection allowed

2. **Drag and Drop:**
   - Drag files over upload area
   - Visual feedback
   - Drop to upload
   - Multiple files supported

**File Display:**
- List of uploaded files
- Each file in green success box
- Individual remove buttons
- File names displayed

**Alternative: Text Input**
- If no files uploaded, user can enter rules in textarea
- Text converted to file for API submission
- Filename: "branding-rules.txt"

---

## 7. Additional Rules Textarea

### Purpose

- Allows users to specify custom compliance rules
- Used when brand guidelines files are not available
- Alternative to uploading brand book

### Behavior

**When to Use:**
- No brand guidelines files uploaded
- Need to add specific rules not in brand book
- Quick compliance checks

**Warning:**
- Label states: "If they conflict with brand guidelines audit results are unpredictable"
- System prioritizes uploaded files over text rules
- Conflicts may cause inconsistent results

**Content:**
- Free-form text input
- No character limit (practical limit: ~5000 chars)
- Plain text format
- Converted to text file for API

---

## 8. Error Handling

### Validation Errors

**Display:**
- Red error box at top of page
- Lists all validation errors
- Bullet points for each error

**Error Types:**
1. "Campaign name is required"
2. "Client name is required"
3. "Ad image is required"
4. "Ad file must be an image (JPG, PNG, GIF, or WebP)"
5. "Either upload brand kit files or enter branding rules"

**Error Clearing:**
- Errors clear when:
  - User fixes the issue
  - User clicks Cancel
  - Form is successfully submitted

### API Errors

**Network Errors:**
- Display: "Failed to validate brand guidelines"
- User can retry

**Authentication Errors:**
- Redirect to login if token invalid
- Show error message

**File Upload Errors:**
- Display specific error from API
- User can re-upload files

---

## 9. State Management

### Component States

```typescript
interface BrandAuditInterfaceState {
  currentStep: 'upload' | 'audit' | 'chatbot';
  uploadData: UploadData | null;
  validationResults: ApiResponse | null;
  isLoading: boolean;
  error: string | null;
}

interface UploadData {
  adFile: File;
  brandKitFiles: File[];
  campaignName: string;
  clientName: string;
  brandingRules: string;
}

interface ValidationResult {
  elementType: string;
  status: string;
  score: number;
  message: string;
  recommendations: string[];
}
```

### State Transitions

**Initial State:**
```
currentStep: 'upload'
uploadData: null
validationResults: null
isLoading: false
error: null
```

**After Form Submission:**
```
currentStep: 'audit'
uploadData: { adFile, brandKitFiles, campaignName, clientName, brandingRules }
validationResults: null
isLoading: true
error: null
```

**After API Response:**
```
currentStep: 'audit'
uploadData: { ... }
validationResults: { success, validationResults, summary }
isLoading: false
error: null (or error message if failed)
```

---

## 10. Chatbot Interface (Alternative Flow)

### Accessing Chatbot

**Option 1: From Upload Page**
- Button: "✨ Audit Your Ads with Prompt AI" (if enabled)
- Opens chatbot interface
- Alternative to file upload

**Option 2: From Results Page**
- May have chatbot option
- For interactive auditing

### Chatbot Features

**Interface:**
- Full-screen chat interface
- AI-powered conversation
- Upload files through chat
- Get compliance feedback interactively

**Navigation:**
- "Back to Upload" button
- Returns to upload form
- Preserves context

---

## 11. Complete User Journey

### Example 1: Standard Audit Flow

```
1. User navigates to /create/agent
2. Sees upload form
3. Enters campaign name: "Summer Launch 2026"
4. Types client name "EcoStyle" → Sees autocomplete suggestions
5. Selects client from dropdown
6. Uploads ad image: "Gemini_Generated_Image_b9b421b9b421b9b4.png" (drag and drop)
7. Uploads brand guidelines: "Gemini_Generated_Image_segxu0segxu0segx.png"
8. Optionally adds additional rules in textarea:
   "Ensure the logo is at least 200px wide and no red colors are used."
9. Clicks "Start Audit"
10. Form validates successfully
11. UI transitions to analyzing state:
    - Left: Shows uploaded ad image
    - Right: Shows "Analyzing Your Ad" with spinner
    - Header: "Analyzing..." button with loader
12. API processes audit (10-30 seconds)
13. Results displayed in split-screen view:
    - Left: Brand Compliance Analysis
      * Overall Compliance Score: 65%
      * Summary cards: 17 Total, 11 Compliant, 6 Issues
      * Key Findings list
    - Right: Validation Results sidebar
      * Overall Compliance Score: 65%
      * Summary cards
      * Search and filter bar
      * Expandable compliance checks list
14. User clicks on "Primary Typography" to expand
15. Sees full description: "Brand guidelines specify primary font: Standard font..."
16. User searches for "Typography" in search bar
17. Filters results to show only "compliant" items
18. User clicks "Download PDF" to export report
19. User reviews all compliance checks
20. User can click "< Back" to start new audit
```

### Example 2: Using Text Rules

```
1. User navigates to /create/agent
2. Fills campaign and client name
3. Uploads ad image
4. Skips brand guidelines upload
5. Enters rules in textarea:
   "Logo must be in top right corner.
    Primary color: #FF5733
    Font: Arial only"
6. Clicks "Start Audit"
7. System uses text rules for validation
8. Results displayed
```

### Example 3: Error Handling

```
1. User navigates to /create/agent
2. Clicks "Start Audit" without filling form
3. Validation errors displayed:
   - "Campaign name is required"
   - "Client name is required"
   - "Ad image is required"
4. User fixes errors
5. Uploads wrong file type for ad
6. Error: "Ad file must be an image"
7. User uploads correct file
8. Audit proceeds successfully
```

---

## 12. API Integration Details

### Validate Brand Guidelines API

**Endpoint:** `POST /api/v1/chatbot/validate-brand-guidelines`

**Authentication:**
- Required: Yes
- Method: Bearer token in Authorization header
- Token source: Session storage (`getAuthToken()`)

**Request Format:**
- Content-Type: `multipart/form-data`
- Files: `adImage` (required), `brandBook` (required)

**Response Format:**
```typescript
{
  success: boolean;
  validationResults: Array<{
    elementType: string;
    status: string;
    score: number;
    message: string;
    recommendations: string[];
  }>;
  summary: {
    totalElements: number;
    compliantElements: number;
    nonCompliantElements: number;
    overallComplianceScore: number;
    overallStatus: string;
  };
}
```

### Get Clients API

**Endpoint:** `GET /api/v1/clients/my-clients`

**Purpose:** Fetch user's clients for autocomplete

**Response:**
```typescript
{
  success: boolean;
  clients: Array<{
    id: string;
    companyName: string;
    email: string;
    approversName: string;
  }>;
}
```

---

## 13. UI Components

### Main Components

1. **BrandAuditInterface** (`/features/agent/BrandAuditInterface.tsx`)
   - Main container component
   - Manages state and step transitions
   - Handles API calls

2. **AIAgent** (`/features/agent/Agent.tsx`)
   - Upload form component
   - Form validation
   - File upload handling
   - Client autocomplete

3. **BrandComplianceEditor** (`/features/agent/BrandComplianceEditor.tsx`)
   - Results display component
   - Image viewer with markers
   - Interactive violation review

4. **SingleTemplateSidebar** (`/features/agent/SingleTemplateSidebar.tsx`)
   - Results summary component
   - Detailed compliance breakdown
   - Recommendations display

5. **BrandAuditChatbot** (`/features/agent/BrandAuditChatbot.tsx`)
   - Chatbot interface component
   - Interactive auditing

### Styling

**Color Scheme:**
- Primary: Blue (#blue-600)
- Success: Green (#green-50, #green-200)
- Error: Red (#red-50, #red-200)
- Background: Gray-50
- Text: Gray-700, Gray-900

**Layout:**
- Two-column grid on upload page
- Split-screen on results page
- Responsive design

---

## 14. Business Rules

### File Requirements

**Ad File:**
- Single file only
- Must be image format
- Max size: Typically 10MB (backend dependent)

**Brand Guidelines:**
- Multiple files allowed
- PDF preferred for documents
- Images accepted
- Text alternative available

### Validation Rules

**Required Fields:**
- Campaign name: Non-empty string
- Client name: Non-empty string
- Ad file: Required
- Brand guidelines: Required (files OR text)

**Optional Fields:**
- Additional rules textarea

### Compliance Scoring

**Score Calculation:**
- Based on element-by-element analysis
- Each element scored 0-100
- Overall score: Average of all elements
- Status determined by score thresholds

**Status Levels:**
- Compliant: 80-100
- Needs Improvement: 50-79
- Non-compliant: 0-49

---

## 15. Key Features Summary

### Core Capabilities

| Feature | Description | Status |
|---------|-------------|--------|
| **Ad Upload** | Upload ad creatives for auditing | ✅ Active |
| **Brand Guidelines Upload** | Upload brand books or compliance docs | ✅ Active |
| **Text Rules** | Enter compliance rules as text | ✅ Active |
| **Client Autocomplete** | Smart client name suggestions | ✅ Active |
| **AI Compliance Analysis** | Automated compliance checking | ✅ Active |
| **Visual Results** | Interactive results with markers | ✅ Active |
| **Detailed Reports** | Element-by-element breakdown | ✅ Active |
| **Recommendations** | Actionable improvement suggestions | ✅ Active |
| **Chatbot Interface** | Interactive auditing via chat | ✅ Active |
| **Download PDF** | Export audit results as PDF | ✅ Active |
| **Search & Filter** | Search and filter compliance checks | ✅ Active |
| **Expandable Details** | Expand compliance checks for details | ✅ Active |
| **Analyzing State** | Visual feedback during analysis | ✅ Active |

### UI/UX Features

| Feature | Description |
|---------|-------------|
| **Drag and Drop** | Easy file upload |
| **Form Validation** | Real-time error checking |
| **Loading States** | Visual feedback during processing |
| **Error Handling** | User-friendly error messages |
| **Responsive Design** | Works on different screen sizes |
| **Split-Screen Results** | Efficient results review |

---

## 16. Troubleshooting

### Common Issues

**Issue 1: "Ad file must be an image"**
- **Cause:** Wrong file type uploaded
- **Solution:** Upload JPG, PNG, GIF, or WebP only

**Issue 2: Client suggestions not showing**
- **Cause:** API error or no clients available
- **Solution:** Check network, verify user has clients

**Issue 3: Validation fails silently**
- **Cause:** Missing required fields
- **Solution:** Check error box at top of page

**Issue 4: Audit takes too long**
- **Cause:** Large files or API processing delay
- **Solution:** Wait for completion, check network

---

## 17. Download PDF Functionality

### PDF Export Feature

**Location:**
- Blue "Download PDF" button in header
- Position: Top right, next to campaign/client name
- Visible only after audit completes

**Functionality:**
- Exports complete audit results as PDF
- Includes:
  - Campaign and client information
  - Overall compliance score
  - Summary statistics
  - All compliance checks with details
  - Recommendations
  - Uploaded ad image (if applicable)

**PDF Contents:**
1. **Cover Page:**
   - Campaign name
   - Client name
   - Audit date
   - Overall compliance score

2. **Summary Section:**
   - Overall compliance score
   - Total elements analyzed
   - Compliant vs non-compliant breakdown
   - Status assessment

3. **Detailed Results:**
   - Each compliance check with:
     - Element type
     - Status
     - Score
     - Assessment message
     - Recommendations

4. **Appendices:**
   - Uploaded ad image
   - Brand guidelines reference (if applicable)

**File Format:**
- PDF format (.pdf)
- Professional layout
- Branded with PixelPlus AI styling
- Suitable for sharing with clients or stakeholders

---

## 18. Search and Filter Features

### Search Functionality

**Location:**
- Search bar in Validation Results sidebar
- Position: Below summary cards
- Always visible when results are displayed

**Features:**
- **Real-time Search:**
  - Filters compliance checks as user types
  - Case-insensitive matching
  - Searches element type names and descriptions

- **Search Scope:**
  - Element type names (e.g., "Primary Typography")
  - Assessment messages
  - Recommendations text

- **Visual Feedback:**
  - Results update instantly
  - No results message if no matches
  - Highlighted matches (if implemented)

### Filter Functionality

**Location:**
- Filter icon next to search bar
- Position: Right side of search input

**Filter Options:**
- **By Status:**
  - All
  - Compliant only
  - Needs Review only
  - Non-compliant only

- **By Score Range:**
  - High (80-100%)
  - Medium (50-79%)
  - Low (0-49%)

- **By Element Type:**
  - Typography
  - Colors
  - Logo
  - Layout
  - Messaging
  - Legal

**Filter Behavior:**
- Can combine multiple filters
- Updates list in real-time
- Shows count of filtered results
- Clear filters option

---

## 19. Expandable Compliance Checks

### Interaction Model

**Collapsed State:**
- Shows header row only:
  - Status icon (checkmark/X/warning)
  - Element name (e.g., "Primary Typography")
  - Score percentage (e.g., "76%")
  - Status tag (e.g., "compliant")
  - Expand arrow (ChevronDown)

**Expanded State:**
- Shows full details:
  - Complete assessment message
  - Issues list (if any)
  - Recommendations list
  - Collapse arrow (ChevronUp)

**Expand/Collapse Behavior:**
- Click anywhere on header row to toggle
- Smooth animation transition
- Maintains scroll position
- Can expand multiple items simultaneously

**Content Structure Example:**
```
[✓] Primary Typography    76%    [compliant]  [▼]
─────────────────────────────────────────────────────────────
Brand guidelines specify primary font: Standard font. 
Ad analysis detected fonts: Not detected. The ad aligns 
well with brand font specifications.

Recommendations:
• Ensure font consistency across all text elements
• Use brand-approved font weights
```

**Status Icons:**
- **Green Checkmark (✓):** Compliant
- **Red X (✗):** Non-compliant
- **Yellow Triangle (⚠):** Needs Review

**Status Tags:**
- **"compliant"** - Green badge
- **"needs review"** - Yellow badge
- **"non-compliant"** - Red badge

---

## 20. Future Enhancements (Potential)

### Possible Features

1. **Batch Auditing:**
   - Upload multiple ads at once
   - Compare compliance across campaigns

2. **Export Reports:**
   - PDF export of audit results
   - Shareable compliance reports

3. **Historical Audits:**
   - Save audit history
   - Track compliance over time

4. **Custom Compliance Rules:**
   - Create reusable rule sets
   - Industry-specific templates

5. **Integration:**
   - Connect to design tools
   - API for automated auditing

---

## Appendix A: Code References

### Main Component Files

- **Frontend:**
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/features/agent/BrandAuditInterface.tsx`
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/features/agent/Agent.tsx`
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/features/agent/BrandComplianceEditor.tsx`
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/features/agent/SingleTemplateSidebar.tsx`
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/features/agent/BrandAuditChatbot.tsx`

- **Backend:**
  - `pixelplus-2--backend/pixelplusaiv2_backend/src/chatbot/chatbot.controller.ts` (brand-audit endpoint)
  - `pixelplus-2--backend/pixelplusaiv2_backend/src/chatbot/chatbot.service.ts` (conductBrandAudit method)

---

## Appendix B: API Reference

### Validate Brand Guidelines

**Endpoint:** `POST /api/v1/chatbot/validate-brand-guidelines`

**Authentication:** Bearer token required

**Request:**
- Content-Type: `multipart/form-data`
- Fields:
  - `adImage`: File (required)
  - `brandBook`: File (required)

**Response:**
```typescript
{
  success: boolean;
  validationResults: ValidationResult[];
  summary: {
    totalElements: number;
    compliantElements: number;
    nonCompliantElements: number;
    overallComplianceScore: number;
    overallStatus: string;
  };
}
```

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Maintained By:** PixelPlus AI Team

