# Concept Genie - Complete Flow Documentation

## Overview

**Concept Genie** is an AI-powered design generation tool that creates compelling ad concepts from text prompts. Users describe their ideas, and Concept Genie generates complete ad designs with images, headlines, subheadlines, body copy, and call-to-action text.

**Route:** `/create/generate`

**Purpose:** Generate ad concepts instantly using AI without requiring design skills.

**Key Features:**
- Generate 2-3 design variations per prompt
- Each design includes image + complete ad copy (headline, subheadline, body, CTA)
- Individual download per design or bulk download
- Generate more variations on demand
- Some designs include overlay text directly on images
- Chat-based interface for iterative refinement

---

## 1. Landing on Concept Genie Page (`/create/generate`)

### Navigation to Concept Genie

**Access Points:**
1. **From `/create` page:**
   - Click "Concept Genie" icon in the circular tool buttons
   - Or click "Concept Genie" in the left sidebar navigation

2. **Direct URL:**
   - Navigate to: `https://app.pixelplusai.com/create/generate`

### Initial UI State (First Interaction)

When a user first lands on the page, they see:

**Visual Elements:**
- **Background:** Gradient background (blue-100 to purple-100) with animated floating orbs
- **Genie Icon:** Large genie image (w-40 h-40) displayed at the top
- **Welcome Message:**
  - Title: "Welcome to Concept Genie!"
  - Subtitle: "Describe your idea, and Concept Genie will instantly generate compelling ad concepts tailored to your brand and audience. No design skills needed—just your imagination."

**Main Input Area:**
- **Container:** White rounded container with border and shadow
- **Textarea:**
  - Placeholder: "Describe your idea, and I'll bring it to life..."
  - Auto-resizing (min: 120px, max: 180px)
  - Supports multi-line input
  - Keyboard shortcuts:
    - `Enter` → Send prompt
    - `Shift + Enter` → New line

**Action Buttons:**
- **"Ask Away" Button:**
  - Position: Bottom right of textarea
  - Icon: Send icon (IoIosSend)
  - State: Disabled when textarea is empty
  - Loading state: Shows spinner when generating

**Helper Text:**
- Bottom of input area:
  - Left: "Press Enter to send, Shift+Enter for new line"
  - Right: "Powered by AI" (indigo-500)

**Pre-written Prompt Suggestions:**
Located at the bottom of the input area, horizontal scrollable buttons:

1. **"✨ Design for me"**
   - Sets prompt: "Design a vibrant social media post for me"

2. **"1:1 Square Format"**
   - Sets prompt: "Create a square 1:1 banner for my website"

3. **"Instagram Ad"**
   - Sets prompt: "Design an Instagram advertisement for a fashion brand"

4. **"Facebook Ad"**
   - Sets prompt: "Create a Facebook ad banner for a local business"

5. **"LinkedIn Ad"**
   - Sets prompt: "Design a professional LinkedIn advertisement"

6. **"1:2 Vertical"**
   - Sets prompt: "Create a vertical 1:2 poster design"

**User Actions:**
1. Type custom prompt in textarea
2. Click a pre-written prompt button (fills textarea)
3. Click "Ask Away" or press Enter to generate
4. Edit prompt before sending

---

## 2. Generating Ad Concepts

### User Flow

```
User enters prompt
  ↓
User clicks "Ask Away" or presses Enter
  ↓
Frontend: handleGenerateDesign()
  ↓
State Changes:
  - isFirstInteraction → false
  - isGenerating → true
  - promptText → cleared
  ↓
Add user message to chat
  ↓
API Call: POST /ai/generate-image-with-text
  ↓
Process response
  ↓
Add assistant message with generated designs
  ↓
Display in Chat Interface
```

### API Call Details

**Endpoint:** `POST /ai/generate-image-with-text`

**Request Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer <accessToken>"
}
```

**Request Body:**
```json
{
  "messages": [
    {
      "role": "SuperAdmin",
      "content": "Design a vibrant social media post for me",
      "type": "text"
    }
  ],
  "source": "leonard"
}
```

**Response Structure:**
```json
{
  "success": true,
  "images": [
    "https://example.com/generated-image-1.jpg",
    "https://example.com/generated-image-2.jpg",
    "https://example.com/generated-image-3.jpg"
  ],
  "title": "Embrace Winter Warmth with Our Water Bottles",
  "subHeadline": "Keep Your Hydration Warm, Even in the Cold",
  "bodyCopy": "Our specially designed water bottles are perfect for winter, ensuring your water stays warm in the chilliest conditions. Stay hydrated, stay warm.",
  "callToAction": "Grab Your Winter-Ready Bottle Today!"
}
```

**Note:** 
- Typically returns 2-3 images per generation
- All images share the same title, subheadline, bodyCopy, and callToAction
- Each image is a visual variation of the same concept
- Some images may have text overlaid directly on them (rendered as part of the design)

**Error Response:**
```json
{
  "success": false,
  "type": "validation_error",
  "message": "Your prompt couldn't be processed. Please try a clearer description.",
  "chatResponse": {
    "content": "I need more details about your design request..."
  },
  "validation": {
    "score": 0.5,
    "feedback": "Prompt is too vague",
    "suggestions": ["Specify target audience", "Mention color preferences"]
  }
}
```

### State Management

**After First Generation:**
- `isFirstInteraction` → `false`
- UI switches from welcome screen to full chat interface
- Chat messages array populated with user and assistant messages

---

## 3. Chat Interface

### UI Layout

Once the first generation is complete, the UI switches to a full-screen chat interface.

**Chat Interface Components:**

1. **Chat Messages Area:**
   - Scrollable container
   - Messages displayed in chronological order
   - User messages: Right-aligned, white background
   - Assistant messages: Left-aligned, with PixelPlus AI branding

2. **Input Area:**
   - Persistent at bottom of screen
   - Textarea with placeholder: "Ask me anything..."
   - "Ask Away" button (blue, with paper airplane icon)
   - Helper text: "Press Enter to send, Shift+Enter for new line"
   - "Powered by AI" text below input
   - Additional action buttons (left side of input):
     - **"Upload Files"** (PaperClip icon) - Upload reference files
     - **"Upload Image"** (Photo icon) - Upload reference asset/image
     - **"Upload Brand Book"** (Book icon) - Upload brand guidelines PDF
   - Pre-written prompts still available (if applicable)

3. **Back to Top Button:**
   - Appears when user scrolls down
   - Fixed position: bottom-right
   - Smooth scroll to top on click

### User Message Display

**Layout:**
- Right-aligned
- White background
- Text content displayed
- Action buttons (Right side of message):
  - **Edit icon** (Pencil) - Edit the message prompt
    - Icon: Light grey pencil outline
    - Position: Right side, bottom of message bubble
    - Hover effect: Opacity change
    - Click: Loads message into textarea for editing
  
  - **Enhance/Generate icon** (Magic/Sparkle) - Enhance or regenerate prompt
    - Icon: Light grey sparkle/magic wand outline
    - Position: Right side, bottom of message bubble (next to Edit)
    - Hover effect: Opacity change
    - Click: Enhances prompt with AI or regenerates with same prompt

**Message Structure:**
```typescript
{
  role: "user",
  content: "Design a vibrant social media post for me",
  timestamp: Date
}
```

### Assistant Message Display

**Layout:**
- Left-aligned (3/4 width)
- White background with border
- Header section:
  - PixelPlus AI avatar (w-5 h-5)
  - "PixelPlus AI" label (indigo-600)
  - Timestamp (gray-500)

**Response Intro:**
- Text: "Here is your response:"

**Design Cards:**
Multiple design cards are displayed vertically (typically 2-3 cards per generation). Each generated design is displayed in a card with:

**Card Structure:**
- **Card Container:**
  - White background with border
  - Rounded corners
  - Padding and spacing
  - Title at top: "Ad Concept: {title}"

**Left Section (2/5 width):**
- **Generated Image:**
  - Max width: 240px
  - Max height: 280px
  - Rounded corners
  - Object-fit: cover
  - **Note:** Some images may have overlay text directly on the image (headlines, subheadlines, or CTAs rendered as part of the design)

- **Individual Download Button (Below Image):**
  - **"Download"** button with dropdown arrow icon
  - Positioned directly below each image
  - Allows downloading individual design
  - Dropdown may provide format options (JPG, PNG, etc.)

**Right Section (3/5 width):**
- **Content Fields:**
  - **Headline:**
    - Label: "Headline:"
    - Value: {title}
    - Font: 14px, #666F8D

  - **Subheadline:**
    - Label: "Subheadline:"
    - Value: {subHeadline}
    - Font: 14px, #666F8D

  - **Body Copy:**
    - Label: "Body Copy:"
    - Value: {bodyCopy}
    - Font: 14px, #666F8D
    - Line-clamp: 4 (truncated with ellipsis)

  - **Call-to-Action (CTA):**
    - Label: "CTA:"
    - Value: {callToAction}
    - Font: 14px, #666F8D
    - Icon: ☑️ checkbox emoji

**Note on Image Variations:**
- Each card shows a different visual variation of the same concept
- Images may differ in:
  - Number of products shown
  - Color combinations
  - Layout composition
  - Overlay text (some images have text overlaid directly on the image)
  - Background elements (props, scenery, effects)

**Bulk Actions (Below all design cards):**
- **"Download All"** (Lightning icon)
  - Gradient background (blue to purple: #E9EEFE to #EBDEFE)
  - Downloads all generated images from the response
  - Position: Below all design cards

- **"Share"** (Pen Tool icon)
  - Gradient background (blue to purple)
  - Share functionality
  - Position: Next to Download All

- **"Generate More"** (Magic icon)
  - Gradient background (blue to purple)
  - Purple button (centered at bottom in some views)
  - Generates additional designs based on same prompt
  - Position: Below all design cards or centered at bottom

### Message Structure

**Assistant Message:**
```typescript
{
  role: "assistant",
  content: "Here are some designs based on your prompt:",
  timestamp: Date,
  images: [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  title: "Revolutionary Smartphone",
  subHeadline: "Experience the future",
  bodyCopy: "Discover the latest innovation...",
  callToAction: "Shop Now"
}
```

---

## 4. User Actions & Interactions

### Generating Designs

**Action:** Click "Ask Away" or press Enter

**Flow:**
1. Validate prompt (not empty)
2. Set `isGenerating = true`
3. Add user message to chat
4. Clear input field
5. Make API call
6. Process response
7. Add assistant message with designs
8. Set `isGenerating = false`

### Editing User Messages

**Action:** Click Edit icon (Pencil) on user message

**Location:**
- Icons appear on the right side of user message bubbles
- Two icons: Pencil (Edit) and Magic/Sparkle (Enhance/Regenerate)
- Position: Bottom right of message, with gap between them

**Edit Prompt Flow:**
1. User clicks Pencil icon on a user message
2. Message content loads into the input textarea
3. User can modify the prompt text
4. User clicks "Ask Away" or presses Enter
5. System calls `handleEditMessage(originalContent, newContent)`
6. Updated message replaces original in chat history
7. New designs generated with edited prompt

**Behavior:**
- Original message is updated in place
- All subsequent messages (assistant responses) remain in history
- New generation uses edited prompt
- Loading message: "Regenerating ad concept with edited prompt..."
- API call: `POST /ai/generate-image-with-text` with `source: "gemini"`

### Enhancing Prompts (Magic/Sparkle Icon)

**Action:** Click Magic/Sparkle icon on user message

**Purpose:**
- Enhance or improve the prompt using AI
- Regenerate designs with the same prompt
- Get better results without manual editing

**Enhance Prompt Flow:**
1. User clicks Magic/Sparkle icon on a user message
2. System detects if prompt should be enhanced
3. If enhancement is available:
   - AI improves the prompt automatically
   - Enhanced prompt replaces original
   - Loading message: "Generating ad concept with enhanced prompt..."
4. If enhancement not available:
   - Regenerates with same prompt
   - Loading message: "Regenerating ad concept with edited prompt..."
5. New designs generated with enhanced/regenerated prompt

**Behavior:**
- May use AI to improve prompt clarity and specificity
- Enhanced prompt marked with `isCorrectedPrompt: true` flag
- Original message updated with enhanced version
- All subsequent messages remain in history
- API call: `POST /ai/generate-image-with-text` with `source: "gemini"`

**Note:** The enhance functionality may vary based on implementation. In some cases, it may simply regenerate with the same prompt rather than enhancing it.

### Regenerating Designs

**Action:** Click "Try again" on a specific design card

**Behavior:**
- Regenerates that specific design
- May replace existing design or add new variant
- Uses same prompt context

### Generating More Designs

**Action:** Click "Generate More" button

**Flow:**
1. Shows "Generating more designs..." message
2. API Call: `POST /ai/generate-image-with-text`
   - Request body:
     ```json
     {
       "messages": [
         {
           "role": "user",
           "content": "<original prompt>",
           "type": "text"
         }
       ],
       "source": "gemini"
     }
     ```
3. Adds new designs to chat
4. Removes generating message

**Note:** Uses `source: "gemini"` for "Generate More" vs `source: "leonard"` for initial generation

### Viewing in Editor

**Action:** Click "View in Editor" on a design card

**Behavior:**
- Opens Polotno editor
- Loads generated design JSON
- User can manually edit design
- Route: `/create/template-custom-editor/{designId}` (if saved)

### Editing with AI

**Action:** Click "Edit with AI" on a design card

**Behavior:**
- Opens AI editing interface
- Similar to AdChat functionality
- User can provide prompts to modify design
- Route: `/create/adchat?templateId={designId}` (if saved)

### Downloading Designs

**Individual Download:**
- **Action:** Click "Download" button below a specific design card
- **Behavior:**
  - Downloads that specific design image
  - Dropdown arrow may provide format options
  - Image saved as individual file
  - Format: Based on original generation (typically JPG/PNG)

**Bulk Download:**
- **Action:** Click "Download All" button
- **Behavior:**
  - Downloads all generated images from current response
  - Images saved as individual files
  - Format: Based on original generation (typically JPG/PNG)

### Sharing Designs

**Action:** Click "Share" button

**Behavior:**
- Opens share modal or native share dialog
- Options: Copy link, Share to social media, Email

---

## 5. Error Handling

### API Errors

**Network Errors:**
- Display: "Network error. Please check your connection and try again."
- User can retry

**Authentication Errors:**
- Display: "Please log in again to continue using Concept Genie."
- Redirect to login if needed

**Validation Errors:**
- Display validation feedback from API
- Show suggestions for improving prompt
- User can edit and resend

**Generation Failures:**
- Display: "Sorry, I couldn't generate designs. Please try again with a different description."
- User can modify prompt and retry

### Error Message Display

**Format:**
- Assistant message with error content
- Red or warning styling
- Actionable suggestions when available

---

## 6. Pre-written Prompt Suggestions

### Available Prompts

| Button Label | Prompt Text | Use Case |
|--------------|-------------|----------|
| ✨ Design for me | "Design a vibrant social media post for me" | General social media design |
| 1:1 Square Format | "Create a square 1:1 banner for my website" | Square format designs |
| Instagram Ad | "Design an Instagram advertisement for a fashion brand" | Instagram-specific ads |
| Facebook Ad | "Create a Facebook ad banner for a local business" | Facebook-specific ads |
| LinkedIn Ad | "Design a professional LinkedIn advertisement" | LinkedIn-specific ads |
| 1:2 Vertical | "Create a vertical 1:2 poster design" | Vertical format designs |

### How They Work

1. **Click Action:**
   - Sets `promptText` state to the prompt value
   - Textarea updates with prompt text
   - User can edit before sending

2. **Visual States:**
   - First button ("Design for me") has indigo background
   - Other buttons have white background with border
   - Hover effects on all buttons

3. **Scrollable:**
   - Horizontal scroll if buttons overflow
   - Hidden scrollbar (scrollbar-hide class)

---

## 7. API Integration Details

### Generate Image with Text API

**Endpoint:** `POST /ai/generate-image-with-text`

**Authentication:**
- Required: Yes
- Method: Bearer token in Authorization header
- Token source: Session storage (`getAuthToken()`)

**Request Format:**
```typescript
{
  messages: Array<{
    role: "SuperAdmin" | "user",
    content: string,
    type: "text"
  }>,
  source: "leonard" | "gemini"
}
```

**Response Format:**
```typescript
{
  success: boolean,
  images?: string[], // Array of image URLs
  title?: string,
  subHeadline?: string,
  bodyCopy?: string,
  callToAction?: string,
  message?: string, // Error message if success: false
  type?: "validation_error",
  chatResponse?: {
    content: string
  },
  validation?: {
    score: number,
    feedback: string,
    suggestions: string[]
  }
}
```

**Source Options:**
- `"leonard"`: Used for initial generation
- `"gemini"`: Used for "Generate More" functionality

### Credit System

**Credit Deduction:**
- Each generation request deducts credits
- Amount depends on user's plan
- Unlimited users: No deduction (tracked for analytics)

**Credit Check:**
- Performed before API call
- If insufficient credits: Show upgrade modal or error

---

## 8. State Management

### Component States

```typescript
interface ConceptGenieState {
  // UI States
  isFirstInteraction: boolean; // Controls welcome screen vs chat
  isGenerating: boolean; // Loading state
  showBackToTop: boolean; // Scroll position indicator
  
  // Data States
  chatMessages: ChatMessage[]; // All messages in conversation
  promptText: string; // Current input text
  
  // Active Tab (if applicable)
  activeTab: "create" | "edit" | "scale";
}
```

### Message Structure

```typescript
interface ChatMessage {
  role: "user" | "assistant";
  content: string;
  timestamp: Date;
  images?: string[]; // Generated image URLs
  title?: string; // Ad headline
  subHeadline?: string; // Ad subheadline
  bodyCopy?: string; // Ad body copy
  callToAction?: string; // CTA text
  isGenerating?: boolean; // Loading indicator
  id?: string; // Unique message ID
}
```

### State Transitions

**Initial Load:**
```
isFirstInteraction: true
  ↓
User sends first prompt
  ↓
isFirstInteraction: false
isGenerating: true
  ↓
API response received
  ↓
isGenerating: false
chatMessages: [userMessage, assistantMessage]
```

---

## 9. UI Components

### Main Components

1. **Design Component** (`/app/main/create/Design.tsx`)
   - Main container component
   - Manages state and API calls
   - Handles first interaction vs chat interface

2. **ChatInterface Component** (`/features/create/ChatInterface.tsx`)
   - Full-screen chat display
   - Message rendering
   - Input area
   - Action buttons

3. **ChatMessageItem Component**
   - Individual message rendering
   - User vs assistant styling
   - Design card layout
   - Action buttons per design

### Styling

**Color Scheme:**
- Primary: Indigo (#1f77fb)
- Background: White with gradient overlay
- Text: Gray scale (#444444, #666F8D)
- Borders: Gray-200

**Animations:**
- Framer Motion for transitions
- Smooth scroll animations
- Loading spinners
- Hover effects on buttons

---

## 10. Integration with Other Features

### Polotno Editor Integration

**"View in Editor" Action:**
- Opens Polotno editor
- Loads design JSON
- Route: `/create/template-custom-editor/{id}`

### AdChat Integration

**"Edit with AI" Action:**
- Opens AdChat interface
- Loads design for AI editing
- Route: `/create/adchat?templateId={id}`

### Template System

**Saving Designs:**
- Generated designs can be saved as templates
- Stored in database
- Accessible in Design Review (`/create/templates`)

---

## 11. User Journey Examples

### Example 1: Quick Social Media Post

```
1. User navigates to /create/generate
2. Sees welcome screen
3. Clicks "✨ Design for me" button
4. Prompt fills: "Design a vibrant social media post for me"
5. User clicks "Ask Away"
6. System generates 2-3 designs
7. User sees designs with images, headlines, body copy
8. User clicks "Download All"
9. Designs downloaded
```

### Example 2: Custom LinkedIn Ad

```
1. User navigates to /create/generate
2. Types: "Create a professional LinkedIn ad for a SaaS product targeting CTOs"
3. Clicks "Ask Away"
4. System generates designs
5. User clicks "Generate More" for additional options
6. User clicks "Edit with AI" on preferred design
7. Redirected to AdChat for further customization
```

### Example 3: Multiple Iterations

```
1. User generates initial designs
2. Clicks "Try again" on a design
3. New variant generated
4. User clicks Edit icon (Pencil) on original prompt message
5. Prompt loads into textarea
6. User modifies prompt
7. Clicks "Ask Away" to resend
8. New designs generated based on updated prompt
```

### Example 4: Enhancing a Prompt

```
1. User generates designs with prompt: "water bottels of winter to keep your water warm"
2. Designs generated but user wants better results
3. User clicks Magic/Sparkle icon on the prompt message
4. System enhances prompt (fixes typo, improves clarity)
5. Enhanced prompt: "water bottles for winter to keep your water warm"
6. New designs generated with enhanced prompt
7. Better quality results achieved
```

---

## 12. Technical Implementation Details

### File Structure

```
pixelplus-2--frontend/
  └── src/
      ├── app/
      │   └── main/
      │       ├── create/
      │       │   └── Design.tsx (Main component)
      │       └── design/
      │           └── Design.tsx (Alternative implementation)
      └── features/
          └── create/
              └── ChatInterface.tsx (Chat UI component)
```

### Key Functions

**handleGenerateDesign():**
- Validates prompt
- Manages state transitions
- Makes API call
- Processes response
- Updates chat messages

**processPrompt():**
- Formats request
- Handles authentication
- Error handling
- Response parsing

**adjustTextareaHeight():**
- Auto-resizes textarea
- Min/max height constraints
- Scrollbar management

### Dependencies

- **React:** Component framework
- **Framer Motion:** Animations
- **Axios/Fetch:** API calls
- **React Icons:** Icon components
- **React Spinners:** Loading indicators

---

## 13. Business Rules

### Generation Limits

- **Per Request:** Typically 2-3 designs per prompt
- **Credit Cost:** Varies by plan
- **Rate Limiting:** May apply for excessive requests

### Content Guidelines

- Prompts should be clear and descriptive
- Inappropriate content may be rejected
- Validation ensures prompt quality

### Design Quality

- AI-generated designs may vary
- Users can regenerate for better results
- Manual editing available via editor

---

## 14. Future Enhancements (Potential)

### Possible Features

1. **Template Selection:**
   - Choose design style before generation
   - Apply brand guidelines

2. **Batch Generation:**
   - Generate multiple variations at once
   - A/B testing variants

3. **Export Options:**
   - Export designs in multiple formats
   - Batch export functionality
   - Custom resolution settings

4. **Brand Integration:**
   - Auto-apply brand colors and fonts
   - Use brand guidelines from Brand Kit
   - Consistent brand styling

5. **Collaboration Features:**
   - Share designs with team members
   - Comment and feedback system
   - Version history

6. **Advanced Customization:**
   - Fine-tune AI generation parameters
   - Style presets
   - Aspect ratio presets

---

## 15. Complete API Flow Diagram

### End-to-End Generation Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CONCEPT GENIE - COMPLETE FLOW                            │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: User Navigation
  User clicks "Concept Genie" from /create page
  ↓
  Navigate to: /create/generate
  ↓
  Component: Design.tsx mounts
  ↓
  Initial State:
    - isFirstInteraction: true
    - chatMessages: []
    - promptText: ""
    - isGenerating: false
  ↓
Step 2: Welcome Screen Display
  UI shows:
    - Genie icon
    - Welcome message
    - Input textarea
    - Pre-written prompt buttons
    - "Ask Away" button
  ↓
Step 3: User Input
  User either:
    A) Types custom prompt
    B) Clicks pre-written prompt button
    C) Edits pre-filled prompt
  ↓
  promptText state updated
  ↓
Step 4: User Triggers Generation
  User clicks "Ask Away" OR presses Enter
  ↓
  handleGenerateDesign() called
  ↓
  Validation:
    - Check promptText.trim() !== ""
    - If empty → return early
  ↓
  State Updates:
    - isFirstInteraction: false
    - isGenerating: true
    - Add user message to chatMessages
    - Clear promptText
  ↓
Step 5: API Request Preparation
  Get access token: getAuthToken()
  ↓
  If no token:
    - Throw error: "No access token found"
    - Show error message
    - Stop flow
  ↓
  Format request body:
    {
      messages: [{
        role: "SuperAdmin",
        content: promptText,
        type: "text"
      }],
      source: "leonard"
    }
  ↓
Step 6: API Call
  POST /ai/generate-image-with-text
  Headers:
    - Content-Type: application/json
    - Authorization: Bearer <token>
  Body: { messages, source }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND PROCESSING                                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend:
    1. Validate request
    2. Check user credits
    3. Process prompt with AI
    4. Generate images
    5. Generate ad copy (title, subheadline, body, CTA)
    6. Return response
  ↓
Step 7: Response Handling
  Check response.success
  ↓
  If success === true:
    Extract:
      - images: string[]
      - title: string
      - subHeadline: string
      - bodyCopy: string
      - callToAction: string
    ↓
    Create assistant message:
      {
        role: "assistant",
        content: bodyCopy || "Here are some designs...",
        timestamp: new Date(),
        images: [...],
        title: "...",
        subHeadline: "...",
        bodyCopy: "...",
        callToAction: "..."
      }
    ↓
    Add to chatMessages
    ↓
    Update UI:
      - Switch to chat interface (if first interaction)
      - Display designs in cards
      - Show action buttons
  ↓
  If success === false:
    Check error type:
      - validation_error → Show validation feedback
      - network_error → Show network error message
      - auth_error → Show login required message
      - other → Show generic error
    ↓
    Add error message to chat
  ↓
Step 8: State Cleanup
  Set isGenerating: false
  ↓
  User can now:
    - Generate more designs
    - Edit messages
    - Download designs
    - View in editor
    - Edit with AI
```

---

## 16. Key Features Summary

### Core Capabilities

| Feature | Description | Status |
|---------|-------------|--------|
| **Text-to-Design** | Generate ad designs from text prompts | ✅ Active |
| **Multi-Design Generation** | Generate 2-3 designs per prompt | ✅ Active |
| **Ad Copy Generation** | Auto-generate headlines, subheadlines, body copy, CTAs | ✅ Active |
| **Pre-written Prompts** | Quick-start prompts for common use cases | ✅ Active |
| **Chat Interface** | Conversational design generation | ✅ Active |
| **Design Cards** | Visual display with metadata, multiple cards (2-3), individual download, overlay text support | ✅ Active |
| **Edit Prompts** | Edit user messages and regenerate designs | ✅ Active |
| **Enhance Prompts** | AI-powered prompt enhancement and improvement | ✅ Active |
| **Regeneration** | Try again for specific designs | ✅ Active |
| **Generate More** | Create additional variants | ✅ Active |
| **Download** | Download generated images | ✅ Active |
| **Editor Integration** | Open designs in Polotno editor | ✅ Active |
| **AI Editing** | Edit designs with AI prompts | ✅ Active |

### UI/UX Features

| Feature | Description |
|---------|-------------|
| **Welcome Screen** | Friendly onboarding experience |
| **Auto-resize Textarea** | Dynamic input field sizing |
| **Keyboard Shortcuts** | Enter to send, Shift+Enter for new line |
| **Loading States** | Visual feedback during generation |
| **Error Handling** | User-friendly error messages |
| **Scroll Management** | Back to top button |
| **Responsive Design** | Works on different screen sizes |
| **Animations** | Smooth transitions and interactions |

---

## 17. Troubleshooting Guide

### Common Issues

#### Issue 1: "No access token found"
**Symptoms:**
- Error message: "No access token found. Please log in again."
- Generation fails immediately

**Solutions:**
1. Check if user is logged in
2. Refresh page to re-authenticate
3. Clear browser storage and login again
4. Check session expiration

#### Issue 2: Generation takes too long
**Symptoms:**
- Loading spinner shows for extended time
- No response received

**Solutions:**
1. Check network connection
2. Verify API endpoint is accessible
3. Check backend service status
4. Try with simpler prompt
5. Check user credits availability

#### Issue 3: Validation errors
**Symptoms:**
- Error: "Your prompt couldn't be processed"
- Validation feedback shown

**Solutions:**
1. Make prompt more specific
2. Add more details about target audience
3. Specify design requirements
4. Follow validation suggestions
5. Use pre-written prompts as examples

#### Issue 4: No images generated
**Symptoms:**
- Response received but images array is empty
- Design cards show without images

**Solutions:**
1. Check image URLs in response
2. Verify image storage service
3. Check network connectivity
4. Try regenerating
5. Contact support if persistent

#### Issue 5: Designs don't match prompt
**Symptoms:**
- Generated designs don't reflect user's intent
- Content is generic or off-topic

**Solutions:**
1. Be more specific in prompt
2. Include target audience details
3. Specify design style preferences
4. Use "Try again" for variants
5. Use "Generate More" for alternatives

---

## 18. Best Practices

### Writing Effective Prompts

**DO:**
- ✅ Be specific about the product/service
- ✅ Mention target audience
- ✅ Specify platform (Instagram, Facebook, LinkedIn)
- ✅ Include design style preferences
- ✅ Mention key messaging points
- ✅ Specify format/aspect ratio if needed

**DON'T:**
- ❌ Use vague descriptions
- ❌ Skip important details
- ❌ Use overly complex sentences
- ❌ Mix multiple unrelated concepts
- ❌ Use inappropriate content

### Example Prompts

**Good:**
```
"Create a professional LinkedIn ad for a B2B SaaS product targeting CTOs. 
Focus on ROI and efficiency. Use a modern, clean design with blue and white colors."
```

**Better:**
```
"Design an Instagram ad for a sustainable fashion brand targeting eco-conscious 
millennials. Use earthy tones, showcase product quality, emphasize ethical 
production. Include a call-to-action for early access to new collection."
```

**Poor:**
```
"Make an ad"
```

---

## 19. Integration Points

### With Other PixelPlus AI Features

1. **Brand Kit Integration:**
   - Use brand colors and fonts
   - Apply brand guidelines
   - Maintain brand consistency

2. **Template System:**
   - Save generated designs as templates
   - Reuse in other workflows
   - Share with team

3. **AdChat Integration:**
   - Edit generated designs with AI
   - Refine designs iteratively
   - Generate variants

4. **Polotno Editor:**
   - Manual design editing
   - Fine-tune layouts
   - Custom adjustments

5. **Client Ads System:**
   - Convert designs to client ads
   - Submit for approval
   - Track in Design Review

---

## 20. Performance Considerations

### Optimization Strategies

1. **Image Loading:**
   - Lazy load images in chat
   - Use optimized image formats
   - Implement progressive loading

2. **State Management:**
   - Minimize re-renders
   - Use React.memo for message components
   - Debounce input if needed

3. **API Calls:**
   - Handle timeouts gracefully
   - Implement retry logic
   - Cache responses when appropriate

4. **Memory Management:**
   - Limit chat history length
   - Clean up unused images
   - Optimize component lifecycle

---

## 21. Security & Privacy

### Data Handling

1. **User Prompts:**
   - Stored temporarily in component state
   - Sent to AI service for processing
   - Not permanently stored (unless saved)

2. **Generated Images:**
   - Stored in cloud storage
   - Accessible via URLs
   - May be cached for performance

3. **Authentication:**
   - Required for all API calls
   - Token-based authentication
   - Session management

4. **Content Moderation:**
   - AI may filter inappropriate content
   - Validation checks prompts
   - User responsibility for compliance

---

## 22. Analytics & Metrics

### Trackable Events

1. **User Actions:**
   - Prompt submissions
   - Pre-written prompt clicks
   - Regeneration requests
   - Download actions
   - Editor opens

2. **Generation Metrics:**
   - Success rate
   - Average generation time
   - Designs per prompt
   - User satisfaction

3. **Usage Patterns:**
   - Most used prompts
   - Popular design styles
   - Platform preferences
   - User engagement

---

## 23. Conclusion

Concept Genie provides a powerful, user-friendly way to generate ad concepts instantly using AI. By combining text prompts with intelligent design generation, users can create professional ad designs without requiring design skills.

**Key Benefits:**
- ⚡ Fast design generation
- 🎨 Professional quality outputs
- 💡 Creative inspiration
- 🔄 Iterative refinement
- 📱 Multi-platform support

**Use Cases:**
- Social media advertising
- Marketing campaigns
- Brand awareness
- Product launches
- Event promotions

---

## Appendix A: Code References

### Main Component Files

- **Frontend:**
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/app/main/create/Design.tsx`
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/app/main/design/Design.tsx`
  - `pixelplus-2--frontend/pixelplusaiv2_frontend/src/features/create/ChatInterface.tsx`

- **Backend:**
  - `pixelplus-2--backend/pixelplusaiv2_backend/src/ai/` (AI service endpoints)

### Key Functions

- `handleGenerateDesign()` - Main generation handler
- `adjustTextareaHeight()` - Input field resizing
- `processPrompt()` - API call wrapper
- `ChatMessageItem` - Message rendering component

---

## Appendix B: API Reference

### Generate Image with Text

**Endpoint:** `POST /ai/generate-image-with-text`

**Authentication:** Bearer token required

**Request:**
```typescript
{
  messages: Array<{
    role: "SuperAdmin" | "user",
    content: string,
    type: "text"
  }>,
  source: "leonard" | "gemini"
}
```

**Response:**
```typescript
{
  success: boolean,
  images?: string[],
  title?: string,
  subHeadline?: string,
  bodyCopy?: string,
  callToAction?: string,
  message?: string,
  type?: "validation_error",
  chatResponse?: {
    content: string
  },
  validation?: {
    score: number,
    feedback: string,
    suggestions: string[]
  }
}
```

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Maintained By:** PixelPlus AI Team