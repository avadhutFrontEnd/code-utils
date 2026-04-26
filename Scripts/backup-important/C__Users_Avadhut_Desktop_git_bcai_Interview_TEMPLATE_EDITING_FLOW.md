# Template Editing Flow Documentation

## Overview

This document explains how the template editing flow works in the PixelPlus AI application, from selecting a template in AdMaker to editing it using prompts in AdChat.

---

## 1. Template Selection Flow

### AdMaker Page (`/create/admaker`)

**Location:** `src/app/main/create/AdMaker.tsx`

**How it works:**
1. User navigates to `/create/admaker`
2. Page displays a grid of templates fetched from the API
3. Each template card shows:
   - Template thumbnail image
   - Template name (if available)
   - Hover effects for better UX

**Template Click Handler:**
```typescript
const handleTemplateClick = (template: Template) => {
    console.log("Selected template:", template);
    navigate(`/create/adchat?templateId=${template.id}`);
};
```

**What happens:**
- When a user clicks on any template card
- The app navigates to `/create/adchat?templateId=<template-id>`
- Example: `http://localhost:3030/create/adchat?templateId=f0fa3c6c-5493-58c4-8716-7b3647681e43`

---

## 2. AdChat Page - Template Loading

### Route: `/create/adchat?templateId=<id>`

**Location:** `src/app/main/create/AdChat.tsx`

### Initial Template Loading

**Step 1: Extract templateId from URL**
```typescript
const [searchParams] = useSearchParams();
const templateId = searchParams.get("templateId");
```

**Step 2: Fetch Template Data**
```typescript
const fetchTemplate = useCallback(async (id: string) => {
    // 1. Get authentication token
    const accessToken = getAuthToken();
    
    // 2. Fetch template metadata from API
    const templateResponse = await axios.get(`${config.apiUri}/templates/${id}`, {
        headers: { Authorization: `Bearer ${accessToken}` }
    });
    
    const template = templateResponse.data;
    
    // 3. Fetch template JSON data
    const jsonResponse = await axios.get(template.json_url);
    const jsonData = jsonResponse.data;
    
    // 4. Load JSON into editor and generate preview image
    const generatedImage = await loadJsonIntoEditor(jsonData);
    
    // 5. Parse template elements for tag overlay
    const { elements, dimensions } = parseTemplateElements(jsonData);
    
    // 6. Update state with template data
    setSelectedTemplate(templateWithImage);
    setTemplateJsonData(jsonData);
    setTemplateElements({ [id]: elements });
    setTemplateDimensions({ [id]: dimensions });
}, []);
```

**Step 3: Load Template on Mount**
```typescript
useEffect(() => {
    if (templateId && !isInitializedRef.current) {
        isInitializedRef.current = true;
        fetchTemplate(templateId);
    }
}, [templateId, fetchTemplate]);
```

---

## 3. Template Editing with Prompts

### How Prompt Processing Works

**Location:** `src/app/main/create/AdChat.tsx` - `processPrompt` function

**Process Flow:**

1. **User enters a prompt** in the chat input (e.g., "Change the headline color to blue")

2. **Prompt is sent to backend:**
```typescript
const response = await axios.post(`${config.apiUri}/chatbot/process-prompt`, {
    prompt: userPrompt,
    jsonData: currentTemplateJsonData
}, {
    headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${accessToken}`,
    },
});
```

3. **Backend processes the prompt** and returns modified JSON data

4. **Frontend updates the template:**
   - Loads new JSON into editor
   - Generates new preview image
   - Updates chat with new template preview
   - Shows success message

**Example Prompts:**
- "Change the headline color to blue"
- "Change the brand image"
- "Change the logo image"
- "Make the background darker"
- "Increase the font size of the headline"
- "Change the call-to-action button color"
- "Add a border around the main image"
- "Change the text color to white"
- "Make the design more modern"
- "Add a shadow effect to the elements"

---

## 4. Chat Interface Features & Buttons

### Main Chat Input Area

**Location:** Bottom of AdChat component (sticky)

#### Input Features:
- **Textarea** for entering prompts
- **Auto-resizing** textarea (min 60px, max 300px)
- **Enter key** to send message
- **Shift + Enter** for new line

#### Image Upload Buttons (Left Side):

1. **Brand Image Button**
   - Icon: Plus icon
   - Function: Upload brand images (up to 3)
   - Usage: Click to select brand images from device
   - Display: Shows count `Brand Image (2/3)`

2. **Background Image Button**
   - Icon: Plus icon
   - Function: Upload background images (up to 3)
   - Usage: Click to select background images
   - Display: Shows count `Background (1/3)`

3. **Logo Button**
   - Icon: Plus icon
   - Function: Upload logo images (up to 3)
   - Usage: Click to select logo images
   - Display: Shows count `Logo (1/3)`

4. **Brand Book Button**
   - Icon: Plus icon
   - Function: Upload PDF brand guidelines
   - Usage: Click to upload brand book PDF
   - State: Shows "Uploading..." while processing

#### Send Button (Right Side):
- **Blue button** with send icon
- **Disabled** when input is empty
- **Sends prompt** to backend for processing

---

### Template Display Features

#### Template Preview Card:
- Shows template image
- Displays template information
- Includes action buttons

#### Tag Overlay Feature:
- **Toggle Tags Button**: Shows/hides element tags on template
- **Available Tags:**
  - Logo Image
  - Brand Image
  - Background Image
  - Brand Name
  - Main Headline, Main Headline 2, Main Headline 3
  - Sub Headline
  - Price, Email, Website, Address
  - Discount Text, Product Detail, Contact
  - Action Button Text, Action Button Vector
  - Scalable Vector, Fixed
  - Service 1-6, Title 1-6

---

### Variant Generation Features

#### Generate Variants Button:
- **Location:** In chat messages when template is displayed
- **Function:** Generates multiple template variants
- **Process:**
  1. Opens modal to upload brand images (min 1, max 3)
  2. User selects images
  3. Clicks "Generate Variants"
  4. System generates multiple variations
  5. Variants displayed in grid

#### Variant Actions (Per Variant):

1. **Download Button** (Dropdown Menu)
   - **PNG** format option
   - **JPEG** format option
   - Downloads individual variant

2. **Save Button**
   - Icon: Save icon (FiSave)
   - Function: Opens approval modal
   - Allows saving variant as ad

3. **Share Button**
   - Opens approval modal
   - Allows sharing variant with clients

4. **Zoom Button**
   - Opens full-screen view of variant
   - Allows detailed inspection

---

### Approval Modal Features

**Triggered by:** Save or Share button on variants

**Features:**
1. **Client Selection**
   - Dropdown to select client
   - Required field

2. **Campaign Information:**
   - Campaign Name (required)
   - Ad Title (required)
   - Ad Description (optional)
   - Campaign Type (dropdown)
   - Priority (Low/Medium/High)
   - Target Audience (text input)
   - Budget (number input)
   - Deadline (date picker)

3. **Comments Section:**
   - Text area for additional notes
   - Checkbox: "Notify creator"

4. **Action Buttons:**
   - **Approve**: Immediately approves the ad
   - **Send for Review**: Sends to review queue
   - **Reject**: Rejects the ad
   - **Cancel**: Closes modal

---

### Static Prompt Pills

**Location:** Below template preview in chat

**Purpose:** Quick action buttons for common edits

**Available Prompts:**
- "Change the headline color to blue"
- "Change the brand image"
- "Change the logo image"
- "Make the background darker"
- "Increase the font size of the headline"
- "Change the call-to-action button color"
- "Add a border around the main image"
- "Change the text color to white"
- "Make the design more modern"
- "Add a shadow effect to the elements"

**Dynamic Prompts:**
- System generates additional prompts based on available tags in template
- Shows relevant prompts for the specific template

---

### Editor Integration

**Custom Editor:**
- **Open Editor Button**: Opens full editor for template
- **Location**: On template preview card
- **Features:**
  - Full Polotno editor interface
  - Direct manipulation of template elements
  - Save changes back to chat

**Editor Actions:**
- **Save**: Saves changes and returns to chat
- **Close**: Closes editor without saving
- **Undo/Redo**: Standard editor controls

---

## 5. Message Types in Chat

### User Messages:
- Text prompts entered by user
- Displayed on right side
- Shows user avatar

### Assistant Messages:
1. **Text Messages:**
   - Responses from AI
   - Explanations and confirmations

2. **Template Messages:**
   - Template preview images
   - Generated variants
   - Includes action buttons

3. **Variant Messages:**
   - Grid of generated variants
   - Each variant has individual actions
   - "Load More" button for pagination

---

## 6. State Management

### Key State Variables:

```typescript
// Template state
const [selectedTemplate, setSelectedTemplate] = useState<Template | null>(null);
const [templateJsonData, setTemplateJsonData] = useState<any>(null);

// Chat state
const [messages, setMessages] = useState<ChatMessage[]>([]);
const [promptText, setPromptText] = useState<string>("");

// Variant state
const [variants, setVariants] = useState<VariantTemplate[]>([]);
const [selectedVariantForShare, setSelectedVariantForShare] = useState<VariantTemplate | null>(null);

// Image upload state
const [brandImages, setBrandImages] = useState<File[]>([]);
const [backgroundImages, setBackgroundImages] = useState<File[]>([]);
const [logoImages, setLogoImages] = useState<File[]>([]);

// UI state
const [isLoading, setIsLoading] = useState(false);
const [isGenerating, setIsGenerating] = useState(false);
const [showTags, setShowTags] = useState<{ [templateId: string]: boolean }>({});
const [isEditorOpen, setIsEditorOpen] = useState(false);
```

---

## 7. API Endpoints Used

### Template Endpoints:
- `GET /templates/{id}` - Fetch template metadata
- `GET {template.json_url}` - Fetch template JSON data

### Chat Endpoints:
- `POST /chatbot/process-prompt` - Process user prompt and modify template
- `POST /chat-sessions` - Create chat session
- `POST /chat-sessions/{id}/messages` - Save messages
- `POST /chat-sessions/{id}/variants` - Save variants

### Ad Creation Endpoints:
- `POST /client-ads` - Create new ad
- `POST /client-ads/{id}/images` - Upload ad image
- `POST /client-ads/{id}/approve-reject` - Approve/reject ad

---

## 8. Figma Templates Integration

### New Feature: Edit Button on Figma Templates

**Location:** `src/app/main/create/FigmaTemplates.tsx`

**Implementation:**
- Added edit pencil icon button on each template card
- Appears on hover (top-right corner)
- Clicking navigates to `/create/adchat?templateId=<figma-template-id>`

**Code:**
```typescript
const handleEditClick = (template: FigmaTemplate, event: React.MouseEvent) => {
    event.stopPropagation();
    navigate(`/create/adchat?templateId=${template.id}`);
};
```

**Result:**
- Figma templates now work exactly like AdMaker templates
- Same editing flow and features available

---

## 9. User Flow Diagram

```
┌─────────────────────┐
│  /create/admaker    │
│  (Template List)    │
└──────────┬──────────┘
           │
           │ Click Template
           ▼
┌─────────────────────────────────────┐
│  /create/adchat?templateId=xxx      │
│  - Loads template                   │
│  - Displays template preview        │
│  - Shows prompt input                │
└──────────┬──────────────────────────┘
           │
           │ User enters prompt
           ▼
┌─────────────────────────────────────┐
│  Process Prompt                     │
│  - Send to backend                  │
│  - Get modified JSON                 │
│  - Update template preview           │
└──────────┬──────────────────────────┘
           │
           │ User clicks action
           ▼
┌─────────────────────────────────────┐
│  Actions Available:                 │
│  - Generate Variants                 │
│  - Download                          │
│  - Save/Share (Approval Modal)       │
│  - Open Editor                       │
│  - Toggle Tags                       │
└─────────────────────────────────────┘
```

---

## 10. Key Components

### Main Components:
1. **AdMaker** (`src/app/main/create/AdMaker.tsx`)
   - Template selection page
   - Grid display of templates

2. **AdChat** (`src/app/main/create/AdChat.tsx`)
   - Main chat interface
   - Template editing
   - Variant generation

3. **ChatMessageItem** (within AdChat.tsx)
   - Individual message rendering
   - Template preview cards
   - Variant grids

4. **FigmaTemplates** (`src/app/main/create/FigmaTemplates.tsx`)
   - Figma template listing
   - Edit button integration

### Supporting Components:
- **BrandImageUploadModal** - Modal for variant generation
- **TemplateApprovalModal** - Approval workflow modal
- **CustomEditor** - Full template editor

---

## 11. Best Practices

### For Developers:

1. **Template ID Handling:**
   - Always convert template IDs to strings when using in URLs
   - Handle both numeric and string IDs

2. **State Management:**
   - Use refs to prevent duplicate template loading
   - Clear editor state before loading new templates

3. **Error Handling:**
   - Always check for authentication token
   - Handle API errors gracefully
   - Show user-friendly error messages

4. **Performance:**
   - Use `useCallback` for expensive operations
   - Memoize template parsing functions
   - Lazy load variant images

### For Users:

1. **Prompt Writing:**
   - Be specific about what to change
   - Mention element names when possible
   - Use clear, concise language

2. **Image Uploads:**
   - Use high-quality images
   - Follow size limits (3 images per type)
   - Ensure images match intended use

3. **Variant Generation:**
   - Upload multiple brand images for better variety
   - Review variants before saving
   - Use approval workflow for client review

---

## 12. Troubleshooting

### Common Issues:

1. **Template not loading:**
   - Check if templateId is in URL
   - Verify authentication token
   - Check network tab for API errors

2. **Prompts not working:**
   - Ensure template is loaded first
   - Check if JSON data is available
   - Verify backend API is responding

3. **Images not uploading:**
   - Check file size limits
   - Verify file format (images: jpg/png, brand book: PDF)
   - Ensure not exceeding 3 images per type

4. **Variants not generating:**
   - Ensure at least 1 brand image uploaded
   - Check if template is loaded
   - Verify API response

---

## Conclusion

The template editing flow provides a seamless experience from template selection to final ad creation. Users can:
- Browse templates in AdMaker or Figma Templates
- Click to edit in AdChat
- Use natural language prompts to modify templates
- Generate variants with brand images
- Save and share templates through approval workflow
- Use full editor for advanced editing

All features are integrated into a single, cohesive chat interface that makes template editing intuitive and powerful.

