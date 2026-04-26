# Client Ads Creation & Approval Flow - Detailed Diagrams

## Overview - Complete User Journey

```
User Journey Flow:
  ↓
1. User lands on /create page
   - Sees AI agents and template grid
   - Can click "Ad Maker" or "AI Ad Agent"
   ↓
2. User navigates to /create/admaker
   - Sees template grid with filters
   - Can search and filter templates
   ↓
3. User clicks a template
   - Redirects to /create/adchat?templateId=...
   - Template loads in editor
   ↓
4. User edits template (optional)
   - Uses prompts to modify template
   - Generates variants
   ↓
5. User clicks "Save" button
   - Opens approval modal
   - Fills campaign details
   - Creates client ad
   ↓
6. Ad is created in "Draft" status
   - User can edit or submit for approval
   ↓
7. User submits for approval (optional)
   - Ad status: "Draft" → "Pending Approval"
   - Client receives notification
   ↓
8. Client reviews ad
   - Sees pending approvals list
   - Reviews ad details
   ↓
9. Client approves or rejects
   - If approved: Ad status → "Approved"
   - If rejected: Ad status → "Rejected"
   - Creator receives notification
```

---

## 1. Landing on Create Page (`/create`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create`

**Left Sidebar Navigation:**
- PixelPlus AI logo
- Menu items:
  - **Ad Maker** (clickable)
  - Concept Genie
  - Compliance Genie
  - Marketing Genie
  - Brand Kit Genie
  - Design Review
  - Templates
  - Clients
  - Settings
  - Subscription Plan

**Main Content Area:**
- Large title: "Create Stunning Designs Instantly!"
- Subtitle: "What will you make this Saturday?"
- Five circular icon buttons:
  - Concept Genie
  - **AI Ad Agent** (highlighted in blue - clickable)
  - AD
  - Brand Kit
  - Design Review
- Text input field: "Describe your idea, and I'll bring it to life"
- "Ask Away" button (with paper airplane icon)
- Section: "Explore PixelPlus AI-Generated Design Ideas"
  - Grid of template cards showing design previews

**User Profile:** Top right shows user name and email

### User Actions Available

1. **Click "Ad Maker" in sidebar** → Navigate to `/create/admaker`
2. **Click "AI Ad Agent" icon** → Navigate to `/create/admaker`
3. **Type in search box** → Search/filter templates
4. **Click "Ask Away"** → Generate designs based on prompt
5. **Click any template card** → Navigate to editor

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Create Page (`/create`)                      │
└─────────────────────────────────────────────────────────────────────────────┘

User lands on page:
  URL: /create
  ↓
User sees:
  - Left sidebar with "Ad Maker" menu item
  - Main area with "AI Ad Agent" icon (highlighted)
  - Template grid below
  ↓
User Action Options:
  Option 1: Click "Ad Maker" in sidebar
  Option 2: Click "AI Ad Agent" icon
  Option 3: Click any template card
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FRONTEND - Navigation Action                             │
└─────────────────────────────────────────────────────────────────────────────┘

If user clicks "Ad Maker" or "AI Ad Agent":
  Frontend: navigate('/create/admaker')
  ↓
  Redirect to: /create/admaker
  ↓
  (Continues to Section 2: Ad Maker Page)
```

---

## 2. Ad Maker Page (`/create/admaker`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create/admaker`

**Left Sidebar:**
- "Ad Maker" is now highlighted in purple (active section)

**Main Content Area:**
- **Filter Section:**
  - "Filters Category: All" (dropdown)
  - "Color: All" (dropdown)
  - "Search templates..." (input field)
  - "Clear Filter" button
- **Template Grid:**
  - Multiple template cards displayed in grid
  - Each card shows:
    - Template thumbnail image
    - Template title (e.g., "Life is an ADVENTURE 50%", "INSURANCE SERVICES", "Christmas SALE")
    - Hover effects

### User Actions Available

1. **Use filters** → Filter templates by category, color, etc.
2. **Search templates** → Type in search box to find specific templates
3. **Click any template card** → Navigate to editor with that template

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FRONTEND - Ad Maker Page (`/create/admaker`)             │
└─────────────────────────────────────────────────────────────────────────────┘

User is on Ad Maker page:
  URL: /create/admaker
  ↓
Frontend loads templates:
  API Call: GET /api/v1/templates
  Headers: { "Authorization": "Bearer <accessToken>" }
  Query Params: { page: 1, limit: 15, category, color, search, ... }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Template Fetching                       │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/templates
  ↓
  Controller: TemplatesController.findAll()
  ↓
  Service: TemplatesService.findAll()
  ↓
  Database Query:
    SQL: SELECT * FROM "template"
         WHERE "deletedAt" IS NULL
         AND (category = $1 OR $1 IS NULL)
         AND (color = $2 OR $2 IS NULL)
         AND (name ILIKE $3 OR $3 IS NULL)
         ORDER BY "createdAt" DESC
         LIMIT $4 OFFSET $5
  ↓
  Returns: List of templates
  [
    {
      id: "f0fa3c6c-5493-58c4-8716-7b3647681e43",
      name: "The World Travel Explore The World",
      image_url: "https://...",
      json_url: "https://...",
      category: "travel",
      ...
    },
    ...
  ]
  ↓
Frontend receives Response:
  List of templates
  ↓
Frontend displays:
  - Template grid with thumbnails
  - Filter options
  - Search box
  ↓
User sees template grid
  ↓
User Action: Click on a template card
  Example: Click "The World Travel Explore The World" template
  ↓
Frontend: handleTemplateClick(template)
  Input: template = { id: "f0fa3c6c-5493-58c4-8716-7b3647681e43", ... }
  ↓
Frontend: navigate(`/create/adchat?templateId=${template.id}`)
  ↓
Redirect to: /create/adchat?templateId=f0fa3c6c-5493-58c4-8716-7b3647681e43
  ↓
(Continues to Section 3: AdChat Editor Page)
```

---

## 3. AdChat Editor Page (`/create/adchat?templateId=...`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create/adchat?templateId=f0fa3c6c-5493-58c4-8716-7b3647681e43`

**Main Content Area:**
- **Template Preview:**
  - Large preview of the selected template
  - Template elements visible
  - Tag overlay (optional - can be toggled)
- **Chat History Sidebar (Optional/Disabled):**
  - Right sidebar for viewing previous chat conversations
  - Currently disabled in code but available for future use
  - Would show: Previous templates, chat history, saved designs
- **Chat Interface:**
  - Chat messages area (shows conversation history)
  - Text input: "Describe your idea, and I'll bring it to life"
  - "Ask Away" button (send icon)
  - **Image Upload Buttons (left side of input):**
    - **Brand Image** button (Plus icon) - Upload up to 3 brand images
    - **Background Image** button (Plus icon) - Upload up to 3 background images
    - **Logo** button (Plus icon) - Upload up to 3 logo images
    - **Brand Book** button (Plus icon) - Upload PDF brand guidelines
  - **Attached Images Display:**
    - Shows preview of uploaded images before sending
    - Displays count: "Brand Image (2/3)", "Background (1/3)", "Logo (1/3)"
    - "Clear All" button to remove all attached images
    - Individual remove buttons for each image
- **Pre-written Prompt Suggestions (below template preview):**
  - Quick action buttons with suggested prompts:
    - "Generate multiple variants of this template"
    - "Change the color scheme"
    - "Update the text content"
    - "Adjust the layout"
    - Other template-specific suggestions
  - Clicking a suggestion fills the chat input or sends the prompt directly
- **Action Buttons (on template):**
  - **Edit** button/icon → Opens Polotno editor (URL remains same: `/create/adchat?templateId=...`)
  - **Save** button (FiSave icon)
  - **Check Brand Guidelines** button
  - **Toggle Tags** checkbox
  - **Download** dropdown (PNG/JPEG)
  - **Generate Variants** button

### User Actions Available

1. **Type prompt in chat** → Modify template using AI prompts
2. **Click pre-written prompt suggestions** → Use suggested prompts (e.g., "Generate multiple variants of this template")
3. **Upload images** → Upload Brand Images, Background Images, Logos, or Brand Book PDF
4. **Click "Edit" button** → Opens Polotno editor overlay/modal (URL stays: `/create/adchat?templateId=...`)
5. **Click "Generate Variants"** → Generate multiple template variations
6. **Navigate variants** → Use pagination to browse through generated variants
7. **Share variant/template** → Share selected variant or template as client ad
8. **Click "Save" button** → Open approval modal to create client ad
9. **Click "Check Brand Guidelines"** → Validate template against brand guidelines
10. **Toggle Tags** → Show/hide element tags on template
11. **Download** → Download template as PNG/JPEG (with watermark if enabled)

### Image Upload Features

**Location:** Left side of chat input area

**Upload Buttons:**
1. **Brand Image Button**
   - Icon: Plus icon (+)
   - Function: Upload brand images (up to 3 images)
   - Display: Shows count "Brand Image (2/3)"
   - Usage: Click to select brand images from device
   - Supported formats: JPEG, PNG, GIF, WebP

2. **Background Image Button**
   - Icon: Plus icon (+)
   - Function: Upload background images (up to 3 images)
   - Display: Shows count "Background (1/3)"
   - Usage: Click to select background images

3. **Logo Button**
   - Icon: Plus icon (+)
   - Function: Upload logo images (up to 3 images)
   - Display: Shows count "Logo (1/3)"
   - Usage: Click to select logo images

4. **Brand Book Button**
   - Icon: Plus icon (+)
   - Function: Upload PDF brand guidelines
   - Usage: Click to upload brand book PDF
   - State: Shows "Uploading..." while processing

**Attached Images Display:**
- Appears above chat input when images are uploaded
- Shows thumbnails of all attached images
- Displays image count for each type
- "Clear All" button to remove all images at once
- Individual remove (X) button for each image
- Images are included when sending prompts to AI

**User Flow:**
```
User clicks "Brand Image" button
  ↓
File picker opens
  ↓
User selects 1-3 brand images
  ↓
Images are added to state
  ↓
Attached Images display appears above input
  ↓
Shows: "Brand Image (2/3)" with thumbnails
  ↓
User can:
  - Remove individual images
  - Click "Clear All" to remove all
  - Send prompt with images attached
  ↓
When user sends prompt:
  Images are included in API request
  AI uses images to modify template
```

### Pre-written Prompt Suggestions

**Location:** Below the template preview image

**Purpose:** Provide quick access to common editing actions

**How It Works:**
1. System analyzes template JSON to find available tags
2. Generates relevant prompts based on found tags
3. Falls back to static prompts if no tags found
4. Always includes fixed prompt: "Generate the multiple variants of this template"
5. Shuffles prompts randomly for variety
6. Displays first 5 prompts by default, with "Show More" button

**UI Behavior:**
- Prompts appear as clickable pill-shaped buttons (chips)
- Shows first 5 prompts initially
- "Show More" button appears if more than 5 prompts available
- Clicking a prompt **fills the chat input field** (user can edit before sending)
- Prompts are context-aware (change based on template tags)

---

## Pre-written Prompts - Complete Reference Table

### Summary

| Prompt Type | Count | Description |
|------------|-------|-------------|
| **Fixed Prompt** | 1 | Always included: "Generate the multiple variants of this template" |
| **Static Prompts** | 10 | Hardcoded fallback prompts (used when no template tags found) |
| **Dynamic Prompts** | ~118 | Generated from template tags (varies by template) |
| **Total Possible** | ~129 | Maximum prompts available (1 fixed + 10 static + 118 dynamic) |
| **Displayed Initially** | 5 | First 5 prompts shown, rest via "Show More" |

---

### 1. Fixed Prompt (Always Included)

| # | Prompt Text |
|---|-------------|
| 1 | "Generate the multiple variants of this template" |

---

### 2. Static Prompts (Fallback - 10 Total)

These are shown when template has no tags or as fallback.

| # | Prompt Text | Category |
|---|-------------|----------|
| 1 | "Change the headline color to blue" | Color/Text |
| 2 | "Change the brand image" | Image |
| 3 | "Change the logo image" | Image |
| 4 | "Make the background darker" | Background |
| 5 | "Increase the font size of the headline" | Typography |
| 6 | "Change the call-to-action button color" | Button/Color |
| 7 | "Add a border around the main image" | Styling |
| 8 | "Change the text color to white" | Color/Text |
| 9 | "Make the design more modern" | Style |
| 10 | "Add a shadow effect to the elements" | Effects |

---

### 3. Dynamic Prompts (Generated from Template Tags - ~118 Total)

These prompts are generated based on tags found in the template JSON. Only prompts for tags that exist in the template are shown.

#### 3.1. Image-Related Tags (6 prompts)

| Tag | Prompts | Count |
|-----|---------|-------|
| **Logo Image** | "Replace the logo image"<br>"Change the logo image" | 2 |
| **Brand Image** | "Replace the brand image"<br>"Change the brand image" | 2 |
| **Background Image** | "Replace the background image"<br>"Change the background image" | 2 |

#### 3.2. Text Content Tags (47 prompts)

| Tag | Prompts | Count |
|-----|---------|-------|
| **Brand Name** | "Change the brand name to"<br>"Update the brand name to" | 2 |
| **Main Headline** | "Change the headline to"<br>"Change the headline color to"<br>"Update the headline text to"<br>"Increase the font size of the headline"<br>"Decrease the font size of the headline"<br>"Change the headline font to" | 6 |
| **Sub Headline** | "Change the sub headline to"<br>"Change the sub headline color to"<br>"Update the sub headline text to"<br>"Increase the font size of the sub headline"<br>"Decrease the font size of the sub headline"<br>"Change the sub headline font to" | 6 |
| **Price** | "Change the price to"<br>"Update the price to"<br>"Increase the font size of the price"<br>"Decrease the font size of the price"<br>"Change the price font to" | 5 |
| **Email** | "Change the email to"<br>"Change the email color to"<br>"Increase the font size of the email"<br>"Decrease the font size of the email"<br>"Change the email font to" | 5 |
| **Website** | "Change the website to"<br>"Update the website URL to"<br>"Increase the font size of the website"<br>"Decrease the font size of the website"<br>"Change the website font to" | 5 |
| **Address** | "Change the address to"<br>"Update the address to"<br>"Increase the font size of the address"<br>"Decrease the font size of the address"<br>"Change the address font to" | 5 |
| **Discount Text** | "Change the discount text to"<br>"Update the discount to"<br>"Increase the font size of the discount text"<br>"Decrease the font size of the discount text"<br>"Change the discount text font to" | 5 |
| **Product Detail** | "Change the product details to"<br>"Update product information to"<br>"Increase the font size of the product detail"<br>"Decrease the font size of the product detail"<br>"Change the product detail font to" | 5 |
| **Contact** | "Change the contact to"<br>"Update contact information to" | 2 |

#### 3.3. Button & Action Tags (7 prompts)

| Tag | Prompts | Count |
|-----|---------|-------|
| **Action Button Text** | "Change the action button text to"<br>"Update action button text to"<br>"Increase the font size of the action button text"<br>"Decrease the font size of the action button text"<br>"Change the action button text font to" | 5 |
| **Action Button Vector** | "Change the action button color to"<br>"Update action button color to" | 2 |

#### 3.4. Vector & Design Elements (1 prompt)

| Tag | Prompts | Count |
|-----|---------|-------|
| **Scalable Vector** | "Update the vector element color to" | 1 |

#### 3.5. Service Tags (30 prompts)

| Tag | Prompts | Count |
|-----|---------|-------|
| **Service 1** | "Change service 1 text to"<br>"Change service 1 color to"<br>"Increase the font size of the service 1"<br>"Decrease the font size of the service 1"<br>"Change the service 1 font to" | 5 |
| **Service 2** | "Change service 2 text to"<br>"Change service 2 color to"<br>"Increase the font size of the service 2"<br>"Decrease the font size of the service 2"<br>"Change the service 2 font to" | 5 |
| **Service 3** | "Change service 3 text to"<br>"Change service 3 color to"<br>"Increase the font size of the service 3"<br>"Decrease the font size of the service 3"<br>"Change the service 3 font to" | 5 |
| **Service 4** | "Change service 4 text to"<br>"Change service 4 color to"<br>"Increase the font size of the service 4"<br>"Decrease the font size of the service 4"<br>"Change the service 4 font to" | 5 |
| **Service 5** | "Change service 5 text to"<br>"Change service 5 color to"<br>"Increase the font size of the service 5"<br>"Decrease the font size of the service 5"<br>"Change the service 5 font to" | 5 |
| **Service 6** | "Change service 6 text to"<br>"Change service 6 color to"<br>"Increase the font size of the service 6"<br>"Decrease the font size of the service 6"<br>"Change the service 6 font to" | 5 |

#### 3.6. Title Tags (27 prompts)

| Tag | Prompts | Count |
|-----|---------|-------|
| **Title 1** | "Change title 1 text to"<br>"Change title 1 color to"<br>"Increase the font size of the title 1"<br>"Decrease the font size of the title 1"<br>"Change the title 1 font to" | 5 |
| **Title 2** | "Change title 2 text to"<br>"Change title 2 color to"<br>"Increase the font size of the title 2"<br>"Decrease the font size of the title 2"<br>"Change the title 2 font to" | 5 |
| **Title 3** | "Change title 3 text to"<br>"Change title 3 color to"<br>"Increase the font size of the title 3"<br>"Decrease the font size of the title 3"<br>"Change the title 3 font to" | 5 |
| **Title 4** | "Change title 4 text to"<br>"Change title 4 color to"<br>"Increase the font size of the title 4"<br>"Decrease the font size of the title 4"<br>"Change the title 4 font to" | 5 |
| **Title 5** | "Change title 5 text to"<br>"Change title 5 color to" | 2 |
| **Title 6** | "Change title 6 text to"<br>"Change title 6 color to"<br>"Increase the font size of the title 6"<br>"Decrease the font size of the title 6"<br>"Change the title 6 font to" | 5 |

**Note:** Title 5 has only 2 prompts (missing font size and font change options)

---

### API Call Flow for Pre-written Prompts

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              PRE-WRITTEN PROMPTS - API CALL FLOW                            │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: User Clicks Pre-written Prompt
  User clicks: "Change the headline color to blue"
  ↓
  Frontend: handleSuggestedPromptClick("Change the headline color to blue")
  ↓
  Action: setPromptText("Change the headline color to blue")
  ↓
  Result:
    - Prompt text fills chat input field
    - Textarea auto-focuses
    - User can edit prompt before sending
    - Prompt is NOT sent automatically
  ↓
Step 2: User Clicks "Ask Away" Button
  User clicks "Ask Away" button (or presses Enter)
  ↓
  Frontend: handleGenerateDesign()
  ↓
  Input: messageToProcess = promptText ("Change the headline color to blue")
  ↓
Step 3: Add User Message to UI
  setMessages([...messages, {
    role: "user",
    type: "text",
    content: "Change the headline color to blue",
    timestamp: new Date()
  }])
  ↓
  setPromptText("") // Clear input field
  ↓
Step 4: Show Loading Message
  setMessages([...messages, {
    role: "assistant",
    type: "text",
    content: "I'm analyzing your request and preparing to make changes to the template...",
    timestamp: new Date()
  }])
  ↓
Step 5: Call processPrompt Function
  const result = await processPrompt("Change the headline color to blue")
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    FRONTEND - processPrompt Function                 │
  └─────────────────────────────────────────────────────────────────────┘
  
  Function: processPrompt(prompt: string)
  ↓
  Step 5.1: Get Access Token
    const accessToken = getAuthToken()
    ↓
    If no token → Throw Error: "No access token found"
  ↓
  Step 5.2: Filter Template JSON Data
    Create filtered copy of templateJsonData
    ↓
    Filter children to only include:
      - Elements with custom.tag property
      - Exclude: "Scalable Vector" and "Fixed" tags
    ↓
    For each element, extract only:
      - id
      - type
      - custom (tag information)
      - name (if exists)
      - text (if exists, for text elements)
      - fontSize (if exists)
      - fill (if exists, for colors)
      - hasSrc: true (if src exists, don't include full src)
    ↓
    This creates optimized JSON for API (smaller payload)
  ↓
  Step 5.3: Make API Call
    API Call: POST /api/v1/chatbot/process-prompt
    Headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer <accessToken>"
    }
    Body: {
      prompt: "Change the headline color to blue",
      jsonData: {
        pages: [{
          children: [
            {
              id: "element-123",
              type: "text",
              custom: { tag: "Main Headline" },
              text: "Summer Sale",
              fontSize: 48,
              fill: "#000000"
            },
            ...
          ]
        }]
      }
    }
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    BACKEND - Process Prompt API                      │
    └─────────────────────────────────────────────────────────────────────┘
    
    Route: POST /api/v1/chatbot/process-prompt
    ↓
    Backend:
      1. Receives prompt and filtered JSON
      2. Analyzes prompt using AI/NLP
      3. Identifies actions needed
      4. Returns list of actions to perform
    ↓
    Response: ProcessPromptResponse
    {
      success: true,
      requiresFile: false,
      actions: [
        {
          action: "change-headline-color",
          tag: "Main Headline",
          requiredData: {
            color: "blue"
          }
        }
      ],
      message: "I'll change the headline color to blue"
    }
    ↓
  Returns: result = ProcessPromptResponse
  ↓
Step 6: Process Actions Returned by API
  if (result.success && result.actions) {
    const actions = result.actions
    ↓
    For each action:
      ↓
      Check action type:
        - "generate-template-variants" → Show image upload modal
        - Image actions (Brand Image, Background Image, Logo) → Validate images
        - Other actions → Process directly
      ↓
      If action is "change-headline-color":
        API Call: POST /api/v1/chatbot/change-headline-color
        Body: {
          jsonData: updatedJsonData,
          color: "blue"
        }
        ↓
        Backend processes and returns updated JSON
        ↓
        updatedJsonData = response.data.jsonData
      ↓
    After all actions processed:
      Load updated JSON into editor
      Generate preview image
      Update template display
  }
  ↓
Step 7: Update UI with Results
  Frontend: loadJsonIntoEditor(updatedJsonData)
  ↓
  Generate base64 preview image
  ↓
  Apply watermark (if enabled)
  ↓
  Update messages:
    - Remove loading message
    - Add success message with updated template
  ↓
  Display updated template in chat
```

### API Endpoints Used

| Step | Endpoint | Method | Purpose |
|------|----------|--------|---------|
| **1** | `/api/v1/chatbot/process-prompt` | POST | Analyze prompt and return actions |
| **2** | `/api/v1/chatbot/{action}` | POST | Execute specific action (e.g., `change-headline-color`) |
| **3** | `/api/v1/chatbot/generate-template-variants` | POST | Generate multiple variants (if prompt requests variants) |

### Request/Response Examples

#### Step 1: Process Prompt API

**Endpoint:** `POST /api/v1/chatbot/process-prompt`

**Request:**
```json
{
  "prompt": "Change the headline color to blue",
  "jsonData": {
    "pages": [{
      "children": [
        {
          "id": "text-123",
          "type": "text",
          "custom": {
            "tag": "Main Headline"
          },
          "text": "Summer Sale",
          "fontSize": 48,
          "fill": "#000000"
        }
      ]
    }]
  }
}
```

**Response:**
```json
{
  "success": true,
  "requiresFile": false,
  "actions": [
    {
      "action": "change-headline-color",
      "tag": "Main Headline",
      "requiredData": {
        "color": "blue"
      }
    }
  ],
  "message": "I'll change the headline color to blue"
}
```

#### Step 2: Execute Action API

**Endpoint:** `POST /api/v1/chatbot/change-headline-color`

**Request:**
```json
{
  "jsonData": {
    "pages": [{
      "children": [
        {
          "id": "text-123",
          "type": "text",
          "custom": {
            "tag": "Main Headline"
          },
          "text": "Summer Sale",
          "fontSize": 48,
          "fill": "#000000"
        }
      ]
    }]
  },
  "color": "blue"
}
```

**Response:**
```json
{
  "success": true,
  "jsonData": {
    "pages": [{
      "children": [
        {
          "id": "text-123",
          "type": "text",
          "custom": {
            "tag": "Main Headline"
          },
          "text": "Summer Sale",
          "fontSize": 48,
          "fill": "#0000FF"
        }
      ]
    }]
  },
  "message": "Headline color changed to blue"
}
```

### Common Action Types

| Action | Endpoint | Description |
|--------|----------|-------------|
| `change-headline-color` | `/api/v1/chatbot/change-headline-color` | Change headline text color |
| `change-headline-text` | `/api/v1/chatbot/change-headline-text` | Change headline text content |
| `change-headline-font-size` | `/api/v1/chatbot/change-headline-font-size` | Change headline font size |
| `replace-logo-image` | `/api/v1/chatbot/replace-logo-image` | Replace logo image |
| `replace-brand-image` | `/api/v1/chatbot/replace-brand-image` | Replace brand image |
| `replace-background-image` | `/api/v1/chatbot/replace-background-image` | Replace background image |
| `generate-template-variants` | `/api/v1/chatbot/generate-template-variants` | Generate multiple variants |
| `handle-unrelated-prompt` | `/api/v1/chatbot/handle-unrelated-prompt` | Handle prompts not related to template |

### Error Handling

**If API returns error:**
```json
{
  "success": false,
  "message": "No headline found in template"
}
```
- Frontend displays error message in chat
- Template remains unchanged
- User can try different prompt

**If action fails:**
- Error message shown for that specific action
- Other actions may still process
- User can retry or modify prompt

---

### How Pre-written Prompts Work - Technical Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              PRE-WRITTEN PROMPTS - GENERATION FLOW                          │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: Template Loads
  URL: /create/adchat?templateId=364d52b4-26c8-5d35-9f7d-f60c1e34f82b
  ↓
Step 2: Fetch Template JSON
  API Call: GET /api/v1/templates/{templateId}
  ↓
  Returns: Template with json_url
  ↓
Step 3: Load Template JSON
  API Call: GET {template.json_url}
  ↓
  Returns: Template JSON (Polotno format)
  {
    pages: [{
      children: [
        { custom: { tag: "Main Headline" }, ... },
        { custom: { tag: "Logo Image" }, ... },
        ...
      ]
    }]
  }
  ↓
Step 4: Find Tags in JSON
  Function: findTagsInJson(jsonData)
  ↓
  Scans JSON recursively for elements with custom.tag property
  ↓
  Returns: Array of found tags
  Example: ["Main Headline", "Logo Image", "Brand Name", "Price"]
  ↓
Step 5: Generate Prompts from Tags
  Function: generatePromptsFromTags(availableTags)
  ↓
  For each tag found:
    - Look up tag in promptMap
    - Add all prompts for that tag to array
  ↓
  Example:
    Tag "Main Headline" → Adds 6 prompts
    Tag "Logo Image" → Adds 2 prompts
    Tag "Price" → Adds 5 prompts
  ↓
  Returns: Array of all relevant prompts
  ↓
Step 6: Add Fixed Prompt
  Function: getRandomPrompts(jsonData)
  ↓
  Always includes: "Generate the multiple variants of this template"
  ↓
  If no tags found:
    → Fallback to static prompts (10 prompts)
    → Returns: [fixedPrompt, ...staticPrompts] (11 total)
  ↓
  If tags found:
    → Returns: [fixedPrompt, ...relevantPrompts] (1 + N total)
  ↓
Step 7: Shuffle Prompts
  Shuffles array randomly for variety
  ↓
Step 8: Memoize Prompts
  useMemo(() => getRandomPrompts(templateJsonData), [templateJsonData])
  ↓
  Prevents prompts from changing on every render
  Only recalculates when template changes
  ↓
Step 9: Display Prompts
  Location: Below template preview
  ↓
  Shows first 5 prompts as pill buttons
  ↓
  If more than 5 prompts:
    Shows "Show More" button
    Clicking shows all prompts
    Button changes to "Show Less"
  ↓
Step 10: User Clicks Prompt
  User clicks: "Change the headline color to blue"
  ↓
  Function: handleSuggestedPromptClick(prompt)
  ↓
  Action: setPromptText("Change the headline color to blue")
  ↓
  Result:
    - Prompt text fills chat input field
    - Textarea auto-focuses
    - User can edit prompt before sending
    - User clicks "Ask Away" to send
```

---

### Display Behavior

| Feature | Behavior |
|---------|----------|
| **Initial Display** | Shows first 5 prompts as pill-shaped buttons |
| **Show More/Less** | Button appears if more than 5 prompts available |
| **Click Action** | Fills chat input field (does NOT send automatically) |
| **Prompt Order** | Randomly shuffled for variety |
| **Context-Aware** | Only shows prompts for tags that exist in template |
| **Fallback** | Uses static prompts if no template tags found |
| **Memoization** | Prompts don't change until template changes |

---

### Example Scenarios

#### Scenario 1: Template with Many Tags
- Template has: Main Headline, Logo Image, Price, Brand Name, Service 1-3
- Generated prompts: ~30+ prompts
- Display: First 5 shown, "Show More" button visible
- User sees: Fixed prompt + relevant prompts for those tags

#### Scenario 2: Template with No Tags
- Template has: No custom tags
- Generated prompts: 11 prompts (1 fixed + 10 static)
- Display: All 11 prompts shown (no "Show More" needed)
- User sees: Fixed prompt + all static fallback prompts

#### Scenario 3: Template with Few Tags
- Template has: Only Logo Image and Brand Name
- Generated prompts: ~5 prompts (1 fixed + 4 from tags)
- Display: All prompts shown
- User sees: Fixed prompt + prompts for Logo and Brand Name

### User Flow Diagram - Template Loading

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - AdChat Editor Page (Template Loading)                │
└─────────────────────────────────────────────────────────────────────────────┘

User navigates to:
  URL: /create/adchat?templateId=364d52b4-26c8-5d35-9f7d-f60c1e34f82b
  ↓
Frontend extracts templateId from URL:
  const [searchParams] = useSearchParams();
  const templateId = searchParams.get("templateId");
  Output: templateId = "364d52b4-26c8-5d35-9f7d-f60c1e34f82b"
  ↓
Frontend: fetchTemplate(templateId)
  ↓
Step 1: Fetch template metadata
  API Call: GET /api/v1/templates/f0fa3c6c-5493-58c4-8716-7b3647681e43
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Template Metadata Fetch                │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/templates/:id
  ↓
  Controller: TemplatesController.findOne(id)
  ↓
  Service: TemplatesService.findOne(id)
  ↓
  Database Query:
    SQL: SELECT * FROM "template"
         WHERE id = $1 AND "deletedAt" IS NULL
  ↓
  Returns: Template entity
  {
    id: "f0fa3c6c-5493-58c4-8716-7b3647681e43",
    name: "The World Travel Explore The World",
    image_url: "https://storage.azure.com/...",
    json_url: "https://storage.azure.com/...",
    ...
  }
  ↓
Frontend receives template metadata
  ↓
Step 2: Fetch template JSON data
  API Call: GET {template.json_url}
  Example: GET https://storage.azure.com/container/templates/xxx.json
  ↓
  Returns: Template JSON data (Polotno format)
  {
    version: "1.0.0",
    pages: [...],
    ...
  }
  ↓
Frontend receives template JSON
  ↓
Step 3: Load template into editor
  Frontend: loadJsonIntoEditor(jsonData)
  ↓
  - Parse JSON data
  - Render template preview
  - Generate preview image
  - Parse template elements for tag overlay
  ↓
Frontend displays:
  - Template preview image
  - Chat interface
  - Action buttons
  ↓
User sees template loaded in editor
  ↓
Frontend displays pre-written prompt suggestions:
  - "Generate multiple variants of this template"
  - "Change the color scheme"
  - "Update the text content"
  - "Adjust the layout"
  - Other template-specific suggestions
  ↓
User can now:
  - Edit template using prompts (type custom or click suggestions)
  - Click "Edit" button → Opens Polotno editor (URL stays: `/create/adchat?templateId=...`)
  - Generate variants
  - Save as client ad
  - Download template
  ↓
When user clicks "Edit" button:
  Frontend: Opens Polotno editor overlay/modal
  - URL remains: /create/adchat?templateId=364d52b4-26c8-5d35-9f7d-f60c1e34f82b
  - Polotno editor interface appears
  - User can edit design directly
  - Changes can be saved back to template
```

### User Flow Diagram - Editing with Prompts

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Prompt-Based Editing Flow                           │
└─────────────────────────────────────────────────────────────────────────────┘

User is on AdChat page:
  URL: /create/adchat?templateId=364d52b4-26c8-5d35-9f7d-f60c1e34f82b
  Template loaded and displayed
  ↓
User sees pre-written prompt suggestions below template preview:
  - "Generate multiple variants of this template"
  - "Change the color scheme"
  - "Update the text content"
  - "Adjust the layout"
  - "Make it more modern"
  - Other suggestions
  ↓
Option 1: User clicks pre-written prompt
  Example: User clicks "Generate multiple variants of this template"
  ↓
  Frontend: handlePromptClick("Generate multiple variants of this template")
  ↓
  Frontend: Either:
    A) Fill chat input with prompt text
    B) Send prompt directly to AI
  ↓
  If sent directly:
    API Call: POST /api/v1/ai/generate-variants (or similar)
    Body: {
      template_id: "364d52b4-26c8-5d35-9f7d-f60c1e34f82b",
      prompt: "Generate multiple variants of this template",
      current_design: { json_url: "..." }
    }
    ↓
    Backend processes with AI
    ↓
    Returns: Multiple variant designs
    ↓
    Frontend displays variants in grid/carousel
    ↓
    User can select a variant to continue editing

Option 2: User types custom prompt
  User types in chat input: "Change the background to blue and make text white"
  ↓
  User clicks "Ask Away" button or presses Enter
  ↓
  Frontend: sendPrompt(promptText)
  ↓
  API Call: POST /api/v1/ai/modify-template (or similar)
  Body: {
    template_id: "364d52b4-26c8-5d35-9f7d-f60c1e34f82b",
    prompt: "Change the background to blue and make text white",
    current_design: { json_url: "..." }
  }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - AI Processing                           │
  └─────────────────────────────────────────────────────────────────────┘
  
  Backend:
    1. Parse prompt
    2. Load current template design
    3. Process with AI (GPT/Vision model)
    4. Generate modified design
    5. Return updated JSON
  ↓
  Returns: Modified template JSON
  {
    version: "1.0.0",
    pages: [/* modified design */],
    ...
  }
  ↓
Frontend receives modified design
  ↓
Frontend: Update template preview
  - Load new JSON into preview
  - Render updated design
  - Show in chat: "Template updated based on your prompt"
  ↓
User sees updated template
  ↓
User can:
  - Continue editing with more prompts
  - Click another pre-written suggestion
  - Click "Generate Variants" for multiple options
  - Click "Save" to create client ad
  - Click "Edit" to open Polotno editor for manual editing
```

### User Flow Diagram - Generate Variants

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Generate Variants Flow                              │
└─────────────────────────────────────────────────────────────────────────────┘

User is on AdChat page:
  Template loaded
  ↓
User clicks "Generate Variants" button
  OR
User clicks pre-written prompt: "Generate multiple variants of this template"
  ↓
Frontend: generateVariants(templateId)
  ↓
API Call: POST /api/v1/ai/generate-variants
  Body: {
    template_id: "364d52b4-26c8-5d35-9f7d-f60c1e34f82b",
    current_design: { json_url: "..." },
    count: 4  // Number of variants to generate
  }
  ↓
Backend processes with AI:
  - Generates multiple variations
  - Different color schemes
  - Different layouts
  - Different text variations
  ↓
Returns: Array of variant designs
  [
    {
      id: "variant-1",
      name: "Variant 1 - Blue Theme",
      json_data: {...},
      preview_url: "https://..."
    },
    {
      id: "variant-2",
      name: "Variant 2 - Red Theme",
      json_data: {...},
      preview_url: "https://..."
    },
    ...
  ]
  ↓
Frontend displays variants:
  - Grid or carousel of variant previews
  - Each variant shows thumbnail
  - "Select" button on each variant
  - "Share" button on each variant (to save as client ad)
  - Pagination controls (if multiple pages)
  ↓
User Actions:
  Option 1: Click "Select" on a variant
    → Load selected variant
    → Replace current template with selected variant
    → Update preview
    → User can continue editing this variant
  Option 2: Click "Share" on a variant
    → Open Save/Approval modal
    → Create client ad from this variant
    → (Same flow as "Save" button)
  Option 3: Navigate pages (if pagination exists)
    → Load more variants
    → Browse through all generated variants
  ↓
User can now:
  - Edit selected variant with prompts
  - Generate more variants
  - Share variant as client ad
  - Save as client ad
```

### User Flow Diagram - Image Upload and Prompt Processing

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Image Upload and Prompt Flow                         │
└─────────────────────────────────────────────────────────────────────────────┘

User uploads images:
  User clicks "Brand Image" button
  ↓
  File picker opens
  ↓
  User selects 2 brand images
  ↓
  Frontend: handleImageUpload('brand', files)
  ↓
  Images added to state: brandImages = [file1, file2]
  ↓
  Attached Images display appears:
    - Shows "Brand Image (2/3)"
    - Displays 2 thumbnails
    - Shows remove buttons
  ↓
User types prompt: "Use these brand images in the template"
  ↓
User clicks "Ask Away" or presses Enter
  ↓
Frontend: sendPrompt(prompt, attachedImages)
  ↓
Frontend prepares FormData:
  - prompt: "Use these brand images in the template"
  - brandImages: [file1, file2]
  - backgroundImages: []
  - logoImages: []
  - jsonData: current template JSON
  ↓
API Call: POST /api/v1/chatbot/process-prompt
  Form Data:
    - prompt: string
    - brandImages: File[]
    - backgroundImages: File[]
    - logoImages: File[]
    - jsonData: JSON
  ↓
Backend processes:
  1. Receives images and prompt
  2. Processes with AI
  3. Applies images to template
  4. Returns modified JSON
  ↓
Frontend receives modified template
  ↓
Frontend updates template preview
  ↓
Images are now part of the template design
```

### Watermark Functionality

**Feature:** Automatic watermark application to downloaded/exported images

**Behavior:**
- Watermark is applied if enabled in user settings
- Applied when:
  - Downloading template as PNG/JPEG
  - Generating preview images
  - Exporting designs
- Watermark is not applied to:
  - Template preview in editor
  - Final saved client ads (after approval)

**User Flow:**
```
User clicks "Download" → PNG
  ↓
Frontend: Generate image from template
  ↓
Check: isWatermarkEnabled?
  ↓
If enabled:
  Apply watermark to image
  ↓
Download watermarked image
  ↓
If disabled:
  Download original image without watermark
```

### Variant Pagination

**Feature:** Navigate through multiple pages of generated variants

**UI Elements:**
- Pagination controls (Previous/Next buttons)
- Page indicator: "Page 1 of 3"
- Variant count: "Showing 4 of 12 variants"
- Loading state when loading more variants

**User Flow:**
```
User generates variants
  ↓
Backend returns 12 variants (3 pages, 4 per page)
  ↓
Frontend displays:
  - Page 1: Variants 1-4
  - "Page 1 of 3"
  - "Previous" button (disabled)
  - "Next" button (enabled)
  ↓
User clicks "Next"
  ↓
Frontend: Load page 2
  API Call: GET /api/v1/variants?page=2&limit=4
  ↓
Frontend displays:
  - Page 2: Variants 5-8
  - "Page 2 of 3"
  - "Previous" button (enabled)
  - "Next" button (enabled)
  ↓
User can navigate through all pages
```

### User Flow Diagram - Save Template as Client Ad

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Save Template as Client Ad Flow                     │
└─────────────────────────────────────────────────────────────────────────────┘

User Action:
  ↓
User has edited template (or using original template)
  ↓
User clicks "Save" button on template
  ↓
Frontend: handleSaveClick(template)
  Input: template or variant data
  ↓
Frontend: Open SaveModal/ApprovalModal
  ↓
User sees Approval Modal with form:
  - Client Selection (dropdown - required)
  - Campaign Name (input - required)
  - Ad Title (input - required)
  - Ad Description (textarea - optional)
  - Campaign Type (dropdown)
  - Priority (dropdown: Low/Medium/High)
  - Target Audience (input)
  - Budget (number input)
  - Deadline (date picker)
  - Comments (textarea)
  - Notify Creator (checkbox)
  - **Save** button (submits ad and sends to client approval)
  - **Cancel** button (closes modal without saving)
  ↓
User fills form:
  - Client: "Client XYZ" (selected from dropdown)
  - Campaign Name: "Summer Sale Campaign 2024"
  - Ad Title: "Summer Sale - 50% Off Everything"
  - Ad Description: "Amazing summer deals..."
  - Campaign Type: "social_media"
  - Priority: "High"
  - Target Audience: "Adults 18-35"
  - Budget: "5000"
  - Deadline: "2024-01-25"
  - Comments: "Please review..."
  - Notify Creator: checked
  ↓
User clicks "Save" button in modal (or "Cancel" to close)
  ↓
If user clicks "Cancel":
  Frontend: Close modal without saving
  ↓
If user clicks "Save":
Frontend: handleSaveAction(formData)
  Input: 
    formData = {
      selectedClient: { id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08", name: "Client XYZ" },
      campaignName: "Summer Sale Campaign 2024",
      adTitle: "Summer Sale - 50% Off Everything",
      adDescription: "Amazing summer deals...",
      campaignType: "social_media",
      priority: "High",
      targetAudience: "Adults 18-35",
      budget: "5000",
      deadline: "2024-01-25",
      comments: "Please review...",
      notifyCreator: true
    }
  ↓
Frontend: Create client ad
  API Call: POST /api/v1/client-ads
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: {
    campaign_name: "Summer Sale Campaign 2024",
    ad_title: "Summer Sale - 50% Off Everything",
    ad_description: "Amazing summer deals...",
    campaign_type: "social_media",
    priority: "High",
    target_audience: "Adults 18-35",
    campaign_objectives: "Increase sales...",
    budget_range: "5000-10000",
    client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/client-ads
  ↓
Guard: @UseGuards(AuthGuard('jwt'))
  ↓
Controller: ClientAdsController.create()
  Input: 
    createAdDto = {
      campaign_name: "Summer Sale Campaign 2024",
      ad_title: "Summer Sale - 50% Off Everything",
      ad_description: "Amazing summer deals...",
      campaign_type: "social_media",
      priority: "High",
      target_audience: "Adults 18-35",
      campaign_objectives: "Increase sales...",
      budget_range: "5000-10000",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
    }
    request.user = { id: 1, role: {...}, sessionId: 123 }
  ↓
  Calls: ClientAdsService.create(createAdDto, req)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: ClientAdsService.create()
  Input: 
    createAdDto { campaign_name, ad_title, ... }
    req.user = { id: 1, role: {...} }
  ↓
  Step 1: Validate required fields
    if (!createAdDto.campaign_name)
      → Throw Error: BadRequestException("campaign_name is required")
    ↓
    If valid → Continue
  ↓
  Step 2: Validate client_id if provided
    if (createAdDto.client_id) {
      ClientRepository.findById(createAdDto.client_id)
      ↓
      ┌─────────────────────────────────────────────────────────────────────┐
      │                    DATABASE QUERY - Client Lookup                  │
      └─────────────────────────────────────────────────────────────────────┘
      
      SQL: SELECT * FROM "client"
           WHERE id = $1 AND "deletedAt" IS NULL
      
      Input: clientId = "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
      ↓
      Output: Client entity OR null
      ↓
      If null → Throw Error: NotFoundException("Client not found")
      If found → Continue
    }
  ↓
  Step 3: Create ClientAd domain object
    ClientAd.create({
      campaign_name: "Summer Sale Campaign 2024",
      ad_title: "Summer Sale - 50% Off Everything",
      ad_description: "Amazing summer deals...",
      campaign_type: "social_media",
      priority: "High",
      target_audience: "Adults 18-35",
      campaign_objectives: "Increase sales...",
      budget_range: "5000-10000",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      created_by: 1,
      status: "Draft",
      approval_status: "Not Submitted"
    })
    ↓
    Output: ClientAd domain object
  ↓
  Step 4: ClientAdRepository.save(clientAd)
    Input: ClientAd domain object
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │              DATABASE QUERY - Client Ad Creation                     │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: INSERT INTO "client_ads" 
         ("campaign_name", "ad_title", "ad_description", "campaign_type", 
          "priority", "target_audience", "campaign_objectives", "budget_range",
          "client_id", "created_by", "status", "approval_status", 
          "created_at", "updated_at")
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW(), NOW())
         RETURNING *
    
    Input: 
      campaign_name = "Summer Sale Campaign 2024"
      ad_title = "Summer Sale - 50% Off Everything"
      ad_description = "Amazing summer deals..."
      campaign_type = "social_media"
      priority = "High"
      target_audience = "Adults 18-35"
      campaign_objectives = "Increase sales..."
      budget_range = "5000-10000"
      client_id = "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
      created_by = 1
      status = "Draft"
      approval_status = "Not Submitted"
    ↓
    Output: ClientAdEntity
    {
      id: "ad-uuid-1234...",
      campaign_name: "Summer Sale Campaign 2024",
      ad_title: "Summer Sale - 50% Off Everything",
      ad_description: "Amazing summer deals...",
      campaign_type: "social_media",
      priority: "High",
      target_audience: "Adults 18-35",
      campaign_objectives: "Increase sales...",
      budget_range: "5000-10000",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      created_by: 1,
      status: "Draft",
      approval_status: "Not Submitted",
      created_at: "2024-01-15T10:30:00Z",
      updated_at: "2024-01-15T10:30:00Z"
    }
    ↓
    Returns: ClientAdEntity
  ↓
  Step 5: Upload template JSON/image to Azure (if provided)
    if (templateJsonData) {
      AzureBlobService.uploadFile({
        container: "client-ads",
        filename: `ad-uuid-1234/template.json`,
        fileBuffer: JSON.stringify(templateJsonData),
        contentType: "application/json"
      })
      ↓
      Output: json_url = "https://storage.azure.com/container/client-ads/ad-uuid-1234/template.json"
      ↓
      Update ad with json_url
      SQL: UPDATE "client_ads" SET "json_url" = $1 WHERE id = $2
    }
    ↓
    if (templateImage) {
      AzureBlobService.uploadFile({
        container: "client-ads",
        filename: `ad-uuid-1234/image.png`,
        fileBuffer: templateImage,
        contentType: "image/png"
      })
      ↓
      Output: ad_image_url = "https://storage.azure.com/container/client-ads/ad-uuid-1234/image.png"
      ↓
      Update ad with ad_image_url
      SQL: UPDATE "client_ads" SET "ad_image_url" = $1 WHERE id = $2
    }
  ↓
  Step 6: Create activity log
    AdActivityService.create({
      ad_id: "ad-uuid-1234...",
      type: "ad_created",
      description: "Ad created",
      user_id: 1
    })
    ↓
    SQL: INSERT INTO "ad_activities" 
         ("ad_id", "type", "description", "user_id", "timestamp")
         VALUES ($1, $2, $3, $4, NOW())
  ↓
  Returns: ClientAdResponseDto
  {
    success: true,
    data: {
      id: "ad-uuid-1234...",
      campaign_name: "Summer Sale Campaign 2024",
      ad_title: "Summer Sale - 50% Off Everything",
      status: "Draft",
      approval_status: "Not Submitted",
      priority: "High",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      created_by: 1,
      created_at: "2024-01-15T10:30:00Z",
      updated_at: "2024-01-15T10:30:00Z"
    }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: ClientAdsController.create()
  Returns: ClientAdResponseDto (HTTP 201 Created)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    success: true,
    data: {
      id: "ad-uuid-1234...",
      campaign_name: "Summer Sale Campaign 2024",
      status: "Draft",
      ...
    }
  }
  ↓
  Frontend: Automatically submit for approval
    API Call: POST /api/v1/client-ads/ad-uuid-1234/submit-for-approval
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
    Body: {
    approval_deadline: formData.deadline ? new Date(formData.deadline).toISOString() : undefined,
    approval_comments: formData.comments || "Ready for client review"
    }
    ↓
    (Continues to Section 4: Submit for Approval)
  ↓
After successful submission:
  Frontend Actions:
    1. Show success notification: "Ad created and submitted for approval"
    2. Close approval modal
    3. Navigate to: /create/templates (Design Review page)
    4. Ad is now visible in the "Design Review" page table with status "Pending Approval"
    5. User can click "Review / Edit" in the Action column to view/edit ad details at /create/templates/{adId}
  ↓
Ad is created, submitted for approval, and visible on /create/templates (Design Review) page
```

### Backend API

**Endpoint:** POST `/api/v1/client-ads`

**Request:**
```json
{
  "campaign_name": "Summer Sale Campaign 2024",
  "ad_title": "Summer Sale - 50% Off Everything",
  "ad_description": "Amazing summer deals on all products",
  "campaign_type": "social_media",
  "priority": "High",
  "target_audience": "Adults 18-35",
  "campaign_objectives": "Increase sales and brand awareness",
  "budget_range": "5000-10000",
  "client_id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "id": "ad-uuid-1234...",
    "campaign_name": "Summer Sale Campaign 2024",
    "ad_title": "Summer Sale - 50% Off Everything",
    "status": "Draft",
    "approval_status": "Not Submitted",
    "priority": "High",
    "client_id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
    "created_by": 1,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "error": {
    "code": "BAD_REQUEST",
    "message": "campaign_name is required"
  }
}
```

---

## 3.5. Design Review Page (`/create/templates`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create/templates`

**Left Sidebar:**
- "Design Review" is highlighted in purple (active section)

**Main Content Area:**
- **Search and Filter Section:**
  - Search bar: "Search your designs..."
  - Filter dropdown: "All Status" (filter by status: Pending Approval, Approved, Draft, etc.)
  - Filter dropdown: "All Priorities" (filter by priority: High, Medium, Low)
  - "Create New" button (top right)
- **Recent Designs Section:**
  - Grid of design cards showing thumbnails
  - Each card displays:
    - Design thumbnail image
    - Title
    - Status badge (e.g., "Pending Approval", "Approved")
    - Last updated date
- **Designs Table:**
  - Table columns:
    - **Thumbnail:** Small preview image of the ad
    - **Title:** Ad/campaign title
    - **Status:** Current status (Pending Approval, Approved, Draft, Rejected, etc.)
    - **Priority:** Priority level with color indicator (High/Medium/Low)
    - **Client Name:** Name of the client associated with the ad
    - **Action:** "Review / Edit" button (blue link)
  - Pagination controls at bottom
  - Shows count: "Showing X of Y results"

### User Actions Available

1. **Search designs** → Type in search bar to filter by title/name
2. **Filter by status** → Select status from "All Status" dropdown
3. **Filter by priority** → Select priority from "All Priorities" dropdown
4. **Click "Review / Edit"** → Navigate to ad detail page at `/create/templates/{adId}`
5. **Click design card** → Navigate to ad detail page
6. **Click "Create New"** → Navigate to template selection or ad creation flow

### User Flow Diagram - Viewing Ad Details

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Design Review Page Navigation                       │
└─────────────────────────────────────────────────────────────────────────────┘

User is on Design Review page:
  URL: /create/templates
  ↓
Frontend loads ads:
  API Call: GET /api/v1/client-ads
  Query Params: { status, priority, search, page, limit }
  ↓
Frontend displays:
  - Table with ads
  - Each row shows: Thumbnail, Title, Status, Priority, Client Name, Action
  ↓
User clicks "Review / Edit" button in Action column
  Example: Click on ad with id "153ae979-0639-44a6-8af2-258b364971d4"
  ↓
Frontend: navigate(`/create/templates/153ae979-0639-44a6-8af2-258b364971d4`)
  ↓
Redirect to: /create/templates/153ae979-0639-44a6-8af2-258b364971d4
  ↓
(Ad detail/edit page loads - shows full ad details, preview, and edit options)
```

---

## 3.5.1. Ad Detail/Edit Page (`/create/templates/{adId}`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create/templates/{adId}`
**Example:** `https://app.pixelplusai.com/create/templates/709a5ab0-ea34-42ce-87c9-31cee23096c1`

**Note:** When clicking "Edit" icon, user is redirected to Polotno editor at `/create/template-custom-editor/{adId}` (not templateId, but adId).

**Left Sidebar:**
- "Design Review" is highlighted in purple (active section)

**Main Content Area:**
- **Page Header:**
  - Ad/Campaign title (e.g., "abc test" or "Summer Sale Campaign 2024")
  - Breadcrumb navigation: Design Review > Ad Title
  - Back button to return to Design Review page
  - Status badge (e.g., "Pending Approval", "Approved", "Draft")
- **Ad Preview Section:**
  - Large preview of the ad design
  - Full-size image/design preview
  - Zoom controls (if applicable)
  - Download options (PNG, JPEG, etc.)
- **Ad Details Section:**
  - **Campaign Information:**
    - Campaign Name (editable if status is Draft)
    - Ad Title (editable if status is Draft)
    - Ad Description (editable if status is Draft)
    - Campaign Type (dropdown, editable if Draft)
    - Priority (dropdown: High/Medium/Low, editable if Draft)
  - **Client Information:**
    - Client Name (display only or editable)
    - Client Email
    - Approver Email
  - **Campaign Details:**
    - Target Audience (editable if Draft)
    - Campaign Objectives (editable if Draft)
    - Budget Range (editable if Draft)
    - Deadline (date picker, editable if Draft)
  - **Approval Information:**
    - Approval Status (display only)
    - Approval Deadline (if submitted)
    - Approval Comments (from creator)
    - Approved/Rejected by (if decided)
    - Approved/Rejected at (timestamp)
    - Approval Comments (from client, if provided)
- **Action Buttons:**
  - **"Submit for Approval"** button (visible if status is "Draft")
  - **"Edit" icon/button** (visible if status is "Draft" or "Rejected") → Redirects to Polotno editor at `/create/template-custom-editor/{adId}`
  - **"Approve"** button (visible if user is client and status is "Pending Approval")
  - **"Reject"** button (visible if user is client and status is "Pending Approval")
  - **"Download"** button (always visible)
  - **"Delete"** button (visible if user has permission)
- **Activity/History Section:**
  - Timeline of activities (created, submitted, approved/rejected)
  - Comments/notes history
  - User actions log

### User Actions Available

1. **View ad preview** → See full-size ad design
2. **Edit ad details** → Modify campaign information (if status is Draft or Rejected)
3. **Click "Edit" icon** → Redirects to Polotno editor at `/create/template-custom-editor/{adId}` to modify design (if status is Draft or Rejected)
4. **Click "Submit for Approval"** → Submit ad for client approval (if status is Draft)
5. **Click "Approve"** → Approve the ad (if user is client and status is Pending Approval)
6. **Click "Reject"** → Reject the ad with comments (if user is client and status is Pending Approval)
7. **Download ad** → Download as PNG, JPEG, etc.
8. **View activity history** → See timeline of all actions and comments
9. **Add comments** → Add notes or feedback (if applicable)

### User Flow Diagram - Loading Ad Details

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Ad Detail Page Loading                               │
└─────────────────────────────────────────────────────────────────────────────┘

User clicks "Review / Edit" on Design Review page:
  From: /create/templates
  Ad ID: 153ae979-0639-44a6-8af2-258b364971d4
  ↓
Frontend: navigate(`/create/templates/153ae979-0639-44a6-8af2-258b364971d4`)
  ↓
Redirect to: /create/templates/153ae979-0639-44a6-8af2-258b364971d4
  ↓
Frontend extracts adId from URL:
  const adId = "153ae979-0639-44a6-8af2-258b364971d4"
  ↓
Frontend: fetchAdDetails(adId)
  ↓
Step 1: Fetch ad metadata
  API Call: GET /api/v1/client-ads/153ae979-0639-44a6-8af2-258b364971d4
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Ad Details Fetch                         │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/client-ads/:id
  ↓
  Controller: ClientAdsController.findOne(id)
  ↓
  Service: ClientAdsService.findOne(id)
  ↓
  Database Query:
    SQL: SELECT * FROM "client_ads"
         WHERE id = $1
         LEFT JOIN "client" ON "client_ads"."client_id" = "client"."id"
         LEFT JOIN "user" AS creator ON "client_ads"."created_by" = creator.id
         LEFT JOIN "user" AS approver ON "client_ads"."approved_by" = approver.id
  ↓
  Returns: ClientAdEntity with related data
  {
    id: "153ae979-0639-44a6-8af2-258b364971d4",
    campaign_name: "Summer Sale Campaign 2024",
    ad_title: "Summer Sale - 50% Off Everything",
    ad_description: "Amazing summer deals...",
    status: "Pending Approval",
    approval_status: "Pending",
    priority: "High",
    client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
    client: {
      id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      name: "Client XYZ",
      email: "client@example.com"
    },
    ad_image_url: "https://storage.azure.com/...",
    json_url: "https://storage.azure.com/...",
    approval_deadline: "2024-01-25T23:59:59Z",
    approval_comments: "Please review...",
    created_by: 1,
    created_at: "2024-01-15T10:30:00Z",
    ...
  }
  ↓
Frontend receives ad metadata
  ↓
Step 2: Fetch ad design JSON (if json_url exists)
  API Call: GET {ad.json_url}
  Example: GET https://storage.azure.com/container/client-ads/153ae979-0639-44a6-8af2-258b364971d4/template.json
  ↓
  Returns: Template JSON data (Polotno format)
  {
    version: "1.0.0",
    pages: [...],
    ...
  }
  ↓
Frontend receives template JSON
  ↓
Step 3: Fetch activity history (optional)
  API Call: GET /api/v1/client-ads/153ae979-0639-44a6-8af2-258b364971d4/activities
  ↓
  Returns: List of activities
  [
    {
      id: "...",
      type: "ad_created",
      description: "Ad created",
      user_id: 1,
      timestamp: "2024-01-15T10:30:00Z"
    },
    {
      id: "...",
      type: "submitted_for_approval",
      description: "Ad submitted for approval",
      user_id: 1,
      timestamp: "2024-01-15T10:40:00Z"
    },
    ...
  ]
  ↓
Frontend receives activity history
  ↓
Frontend displays:
  - Ad preview image
  - Ad details form (editable if status is Draft)
  - Status badge
  - Action buttons (based on status and user role)
  - Activity timeline
  ↓
User sees ad detail/edit page with all information
  ↓
User can now:
  - View ad preview
  - Edit ad details (if Draft or Rejected)
  - Click "Edit" icon to open Polotno editor (if Draft or Rejected)
  - Submit for approval (if Draft)
  - Approve/Reject (if client and Pending Approval)
  - Download ad
  - View activity history
```

### User Flow Diagram - Edit Ad Design (From Ad Detail Page)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Edit Ad Design Flow (From Ad Detail)                 │
└─────────────────────────────────────────────────────────────────────────────┘

User is on ad detail page:
  URL: /create/templates/709a5ab0-ea34-42ce-87c9-31cee23096c1
  Ad status: "Draft" or "Rejected"
  ↓
User clicks "Edit" icon/button
  ↓
Frontend: navigate(`/create/template-custom-editor/709a5ab0-ea34-42ce-87c9-31cee23096c1`)
  ↓
Redirect to: /create/template-custom-editor/709a5ab0-ea34-42ce-87c9-31cee23096c1
  ↓
Frontend extracts adId from URL:
  const adId = "709a5ab0-ea34-42ce-87c9-31cee23096c1"
  ↓
Frontend: Load Polotno editor
  ↓
Step 1: Fetch ad data
  API Call: GET /api/v1/client-ads/709a5ab0-ea34-42ce-87c9-31cee23096c1
  ↓
  Returns: Ad data with json_url
  {
    id: "709a5ab0-ea34-42ce-87c9-31cee23096c1",
    json_url: "https://storage.azure.com/container/client-ads/709a5ab0-ea34-42ce-87c9-31cee23096c1/template.json",
    ...
  }
  ↓
Step 2: Fetch design JSON
  API Call: GET {ad.json_url}
  Example: GET https://storage.azure.com/container/client-ads/709a5ab0-ea34-42ce-87c9-31cee23096c1/template.json
  ↓
  Returns: Template JSON data (Polotno format)
  {
    version: "1.0.0",
    pages: [...],
    ...
  }
  ↓
Step 3: Load design into Polotno editor
  Frontend: loadJsonIntoPolotnoEditor(jsonData)
  ↓
Polotno editor displays:
  - Full editor interface
  - Design loaded from JSON
  - All editing tools available
  ↓
User edits design:
  - Modify colors
  - Update text
  - Adjust layout
  - Add/remove elements
  ↓
User clicks "Save" in Polotno editor
  ↓
Frontend: Save updated design
  - Convert Polotno editor state to JSON
  - Upload JSON to Azure
  API Call: POST /api/v1/client-ads/709a5ab0-ea34-42ce-87c9-31cee23096c1/upload-json
  Form Data:
    - file: [updated_json_data]
  ↓
Backend uploads JSON and updates ad.json_url
  ↓
Frontend: Option to navigate back to ad detail page
  OR: Stay in editor for further edits
  ↓
Ad design is updated (status remains "Draft" or "Rejected")
```

---

## 3.5.2. Polotno Editor Page (`/create/template-custom-editor/{adId}`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create/template-custom-editor/{adId}`
**Example:** `https://app.pixelplusai.com/create/template-custom-editor/709a5ab0-ea34-42ce-87c9-31cee23096c1`

**Note:** This route uses `{adId}` (client ad ID), not `{templateId}`. This is the Polotno editor for editing existing client ads.

**Main Content Area:**
- **Full-screen Polotno Editor:**
  - Complete Polotno editor interface
  - Design canvas
  - Toolbar with editing tools
  - Properties panel
  - Layers panel
  - Save button
  - Export/Download options

### User Actions Available

1. **Edit design** → Modify ad design using Polotno tools
2. **Save changes** → Save updated design to ad's json_url
3. **Export/Download** → Download as PNG, JPEG, etc.
4. **Navigate back** → Return to ad detail page

### User Flow Diagram

```
User navigates to Polotno editor:
  URL: /create/template-custom-editor/709a5ab0-ea34-42ce-87c9-31cee23096c1
  ↓
Frontend extracts adId from URL:
  const adId = "709a5ab0-ea34-42ce-87c9-31cee23096c1"
  ↓
Frontend: Load ad data and design
  API Call: GET /api/v1/client-ads/709a5ab0-ea34-42ce-87c9-31cee23096c1
  ↓
  Returns: Ad data with json_url
  ↓
Frontend: Fetch design JSON from json_url
  API Call: GET {ad.json_url}
  ↓
  Returns: Template JSON (Polotno format)
  ↓
Frontend: Initialize Polotno editor
  - Load JSON into Polotno
  - Display editor interface
  ↓
User edits design in Polotno editor
  ↓
User clicks "Save"
  ↓
Frontend: Convert Polotno state to JSON
  ↓
Frontend: Upload updated JSON
  API Call: POST /api/v1/client-ads/709a5ab0-ea34-42ce-87c9-31cee23096c1/upload-json
  Form Data:
    - file: [updated_json_data]
  ↓
Backend: Upload to Azure, update ad.json_url
  ↓
Frontend: Show success notification
  ↓
User can:
  - Continue editing
  - Navigate back to ad detail page
  - Export/Download design
```

**Key Difference from AdChat Editor:**
- **AdChat Editor** (`/create/adchat?templateId=...`): 
  - Uses `templateId` in query parameter
  - Edit button opens Polotno editor overlay (URL stays same)
  - For editing templates before creating ads
  
- **Polotno Editor** (`/create/template-custom-editor/{adId}`):
  - Uses `adId` in URL path
  - Full page redirect
  - For editing existing client ads

---

### Backend API

**Endpoint:** GET `/api/v1/client-ads/{id}`

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "id": "153ae979-0639-44a6-8af2-258b364971d4",
    "campaign_name": "Summer Sale Campaign 2024",
    "ad_title": "Summer Sale - 50% Off Everything",
    "ad_description": "Amazing summer deals on all products",
    "status": "Pending Approval",
    "approval_status": "Pending",
    "priority": "High",
    "campaign_type": "social_media",
    "target_audience": "Adults 18-35",
    "campaign_objectives": "Increase sales and brand awareness",
    "budget_range": "5000-10000",
    "client_id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
    "client": {
      "id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      "name": "Client XYZ",
      "email": "client@example.com"
    },
    "ad_image_url": "https://storage.azure.com/container/client-ads/153ae979-0639-44a6-8af2-258b364971d4/image.png",
    "json_url": "https://storage.azure.com/container/client-ads/153ae979-0639-44a6-8af2-258b364971d4/template.json",
    "approval_deadline": "2024-01-25T23:59:59Z",
    "approval_comments": "Please review the campaign details",
    "created_by": 1,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:40:00Z",
    "submitted_at": "2024-01-15T10:40:00Z"
  }
}
```

**Endpoint:** GET `/api/v1/client-ads/{id}/activities`

**Response (Success):**
```json
{
  "success": true,
  "data": [
    {
      "id": "activity-uuid-1",
      "ad_id": "153ae979-0639-44a6-8af2-258b364971d4",
      "type": "ad_created",
      "description": "Ad created",
      "user_id": 1,
      "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "timestamp": "2024-01-15T10:30:00Z"
    },
    {
      "id": "activity-uuid-2",
      "ad_id": "153ae979-0639-44a6-8af2-258b364971d4",
      "type": "submitted_for_approval",
      "description": "Ad submitted for approval",
      "user_id": 1,
      "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "timestamp": "2024-01-15T10:40:00Z"
    }
  ]
}
```

---

## 3.6. Clients Management Page (`/create/clients`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create/clients`

**Left Sidebar:**
- "Clients" is highlighted in purple (active section)

**Main Content Area:**
- **Page Header:**
  - Large title: "Clients"
  - Description: "Manage your client relationships and partnerships."
  - **"+ Add New Client" button** (top right, blue button with plus icon)
- **Client List Header:**
  - Shows count: "All Clients (X)" where X is the number of clients
- **Clients Table:**
  - Table columns:
    - **Brand Logo:** Circular logo/avatar for the client (shows initials if no logo)
    - **Client Name:** Name of the client
    - **Client Email Id:** Primary email address of the client
    - **Approver Email Id:** Email address of the person who approves ads for this client
    - **Assets Uploaded:** 
      - Shows uploaded assets with icons:
        - "Logo" with checkmark (✓) or X icon
        - "Brand Color" with checkmark (✓) or X icon
        - Other assets as applicable
    - **Status:** Client status badge:
      - "Pending" (yellow/orange pill-shaped badge)
      - "Approved" (green pill-shaped badge)
      - Other statuses as applicable
    - **Action:** "Edit" button (blue text link) to edit client details
  - Each row represents one client
  - Table shows all registered clients

### User Actions Available

1. **Click "+ Add New Client"** → Open modal/form to create a new client
2. **Click "Edit" in Action column** → Navigate to client branding page at `/create/clients/{clientId}/branding`
3. **View client information** → See client details, email, approver, assets, and status
4. **Filter/Search clients** → (If search/filter functionality exists)

### User Flow Diagram - Client Management

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Clients Management Page                              │
└─────────────────────────────────────────────────────────────────────────────┘

User navigates to Clients page:
  URL: /create/clients
  ↓
Frontend loads clients:
  API Call: GET /api/v1/clients
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Clients Fetching                        │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/clients
  ↓
  Controller: ClientsController.findAll()
  ↓
  Service: ClientsService.findAll()
  ↓
  Database Query:
    SQL: SELECT * FROM "client"
         WHERE "deletedAt" IS NULL
         ORDER BY "createdAt" DESC
  ↓
  Returns: List of clients
  [
    {
      id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      name: "Anish",
      email: "anishrane1305@gmail.com",
      approver_email: "saurabh.yadav@chintandev.in",
      status: "Approved",
      logo_url: "...",
      brand_colors: [...],
      ...
    },
    ...
  ]
  ↓
Frontend receives Response:
  List of clients
  ↓
Frontend displays:
  - Client table with all columns
  - Client count in header
  - "+ Add New Client" button
  ↓
User sees client management interface
  ↓
User Actions:
  Option 1: Click "+ Add New Client"
    → Open create client modal/form
  Option 2: Click "Edit" on a client row
    → Navigate to: /create/clients/{clientId}/branding
    Example: /create/clients/5d4922f4-647d-4810-bdea-94b00800290b/branding
  Option 3: View client details in table
```

### Purpose of This Page

- **Client Management:** Create, view, and edit client information
- **Client Selection:** When creating ads, users can select from clients listed here
- **Asset Tracking:** See which clients have uploaded logos, brand colors, etc.
- **Status Management:** Track client approval status (Pending, Approved, etc.)
- **Approver Information:** View who is responsible for approving ads for each client

**Note:** This page is separate from the ad approval flow. It's for managing client information. Ads sent for approval appear on the Design Review page (`/create/templates`), not here.

---

## 3.7. Client Branding/Edit Page (`/create/clients/{clientId}/branding`)

### What User Sees

**Page URL:** `https://app.pixelplusai.com/create/clients/{clientId}/branding`
**Example:** `https://app.pixelplusai.com/create/clients/5d4922f4-647d-4810-bdea-94b00800290b/branding`

**Left Sidebar:**
- "Clients" is highlighted in purple (active section)

**Main Content Area:**
- **Page Header:**
  - Client name/title (e.g., "Edit Client: Anish" or "Client Branding")
  - Breadcrumb navigation: Clients > Client Name > Branding
  - Back button or navigation to return to clients list
- **Branding/Edit Form Sections:**
  - **Client Information Section:**
    - Client Name (input field)
    - Client Email Id (input field)
    - Approver Email Id (input field)
    - Status (dropdown or toggle)
  - **Brand Assets Section:**
    - **Logo Upload:**
      - Upload area/button for client logo
      - Preview of current logo (if uploaded)
      - Remove/Replace logo option
      - File format requirements (PNG, JPG, SVG, etc.)
    - **Brand Colors:**
      - Color picker or input fields for brand colors
      - Primary color
      - Secondary color(s)
      - Accent colors
      - Preview of color palette
    - **Additional Assets:**
      - Fonts/Typography settings
      - Brand guidelines upload
      - Other brand assets
  - **Save/Cancel Buttons:**
    - "Save" button (saves changes)
    - "Cancel" button (discards changes and returns to clients list)

### User Actions Available

1. **Edit client information** → Update client name, email, approver email
2. **Upload/Replace logo** → Upload new logo or replace existing one
3. **Set brand colors** → Define primary, secondary, and accent colors
4. **Upload brand assets** → Add fonts, guidelines, or other brand materials
5. **Click "Save"** → Save all changes and update client
6. **Click "Cancel"** → Discard changes and return to clients list

### User Flow Diagram - Editing Client Branding

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Client Branding Page Navigation                      │
└─────────────────────────────────────────────────────────────────────────────┘

User clicks "Edit" on client row:
  From: /create/clients
  Client ID: 5d4922f4-647d-4810-bdea-94b00800290b
  ↓
Frontend: navigate(`/create/clients/5d4922f4-647d-4810-bdea-94b00800290b/branding`)
  ↓
Redirect to: /create/clients/5d4922f4-647d-4810-bdea-94b00800290b/branding
  ↓
Frontend loads client data:
  API Call: GET /api/v1/clients/5d4922f4-647d-4810-bdea-94b00800290b
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Client Data Fetching                     │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/clients/:id
  ↓
  Controller: ClientsController.findOne(id)
  ↓
  Service: ClientsService.findOne(id)
  ↓
  Database Query:
    SQL: SELECT * FROM "client"
         WHERE id = $1 AND "deletedAt" IS NULL
  ↓
  Returns: Client entity
  {
    id: "5d4922f4-647d-4810-bdea-94b00800290b",
    name: "Anish",
    email: "anishrane1305@gmail.com",
    approver_email: "saurabh.yadav@chintandev.in",
    logo_url: "https://...",
    brand_colors: ["#FF5733", "#33FF57"],
    status: "Approved",
    ...
  }
  ↓
Frontend receives Response:
  Client data
  ↓
Frontend displays:
  - Client branding/edit form
  - Pre-filled with existing client data
  - Logo preview (if exists)
  - Brand colors (if set)
  ↓
User sees client branding page with current data
  ↓
User Actions:
  Option 1: Edit client information fields
  Option 2: Upload/update logo
  Option 3: Set/update brand colors
  Option 4: Click "Save" → Update client
    API Call: PUT /api/v1/clients/5d4922f4-647d-4810-bdea-94b00800290b
    Body: { name, email, approver_email, logo, brand_colors, ... }
    ↓
    After success: Navigate back to /create/clients or show success message
  Option 5: Click "Cancel" → Navigate back to /create/clients
```

### Backend API

**Endpoint:** GET `/api/v1/clients/{id}`

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "id": "5d4922f4-647d-4810-bdea-94b00800290b",
    "name": "Anish",
    "email": "anishrane1305@gmail.com",
    "approver_email": "saurabh.yadav@chintandev.in",
    "logo_url": "https://storage.azure.com/...",
    "brand_colors": ["#FF5733", "#33FF57", "#3357FF"],
    "status": "Approved",
    "created_at": "2024-01-10T08:00:00Z",
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

**Endpoint:** PUT `/api/v1/clients/{id}`

**Request:**
```json
{
  "name": "Anish",
  "email": "anishrane1305@gmail.com",
  "approver_email": "saurabh.yadav@chintandev.in",
  "logo": "<file>",
  "brand_colors": ["#FF5733", "#33FF57", "#3357FF"],
  "status": "Approved"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "id": "5d4922f4-647d-4810-bdea-94b00800290b",
    "name": "Anish",
    "email": "anishrane1305@gmail.com",
    "approver_email": "saurabh.yadav@chintandev.in",
    "logo_url": "https://storage.azure.com/...",
    "brand_colors": ["#FF5733", "#33FF57", "#3357FF"],
    "status": "Approved",
    "updated_at": "2024-01-15T11:00:00Z"
  }
}
```

---

## 4. Submit Ad for Approval

### What User Sees

**Scenario 1: From AdChat Editor**
- User has created ad and clicked "Save" in approval modal
- Ad is automatically created and submitted for approval
- User is redirected to `/create/templates` (Design Review page)
- Ad appears in the table with status "Pending Approval"

**Scenario 2: From Design Review Page (`/create/templates`)**
- User navigates to Design Review page
- Sees list of all ads in a table format
- Can filter by status (All Status, Pending Approval, Approved, etc.)
- Can filter by priority (All Priorities, High, Medium, Low)
- Can search designs using search bar
- Each ad row shows: Thumbnail, Title, Status, Priority, Client Name, and Action button
- Clicking "Review / Edit" in Action column redirects to `/create/templates/{adId}`

**Scenario 3: From Ad Detail Page (`/create/templates/{adId}`)**
- User is on ad detail/edit page
- Ad status: "Draft" (if not yet submitted)
- User sees "Submit for Approval" button (if status is Draft)

**Submit for Approval Modal:**
- Approval Deadline: Date picker (optional)
- Comments: Text area (optional)
- Notify Client: Checkbox (default: checked)
- "Submit" button

### User Actions Available

1. **Click "Submit for Approval" button** → Open submission modal
2. **Fill submission form** → Enter deadline and comments
3. **Click "Submit"** → Submit ad for client approval

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Submit for Approval Flow                            │
└─────────────────────────────────────────────────────────────────────────────┘

Scenario 1: From AdChat Editor (Auto-submit)
  ↓
User clicked "Approve" in approval modal after creating ad
  ↓
Frontend automatically submits for approval:
  API Call: POST /api/v1/client-ads/ad-uuid-1234/submit-for-approval
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: {
    approval_deadline: "2024-01-25T23:59:59Z",
    approval_comments: formData.comments || "Ready for client review"
  }
  ↓
  (Continues to Backend flow below)

Scenario 2: From Ad Detail Page (Manual submit)
  ↓
User is on ad detail/edit page
  ↓
User sees:
  - Ad status: "Draft"
  - "Submit for Approval" button (enabled)
  ↓
User clicks "Submit for Approval" button
  ↓
Frontend: Open submission modal
  ↓
User sees modal with form:
  - Approval Deadline: Date picker (optional)
  - Comments: Text area (optional)
  - Notify Client: Checkbox (default: checked)
  ↓
User fills form:
  - Approval Deadline: "2024-01-25"
  - Comments: "Please review the campaign details..."
  - Notify Client: checked
  ↓
Frontend Validation:
  - Deadline must be in the future (if provided)
  - Ad must have client assigned (check ad.client_id)
  ↓
User clicks "Submit" button
  ↓
Data Prepared:
  {
    approval_deadline: "2024-01-25T23:59:59Z",
    approval_comments: "Please review the campaign details..."
  }
  ↓
API Call: POST /api/v1/client-ads/ad-uuid-1234/submit-for-approval
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: { approval_deadline, approval_comments }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/client-ads/:id/submit-for-approval
  ↓
Guard: @UseGuards(AuthGuard('jwt'))
  ↓
Controller: ClientAdsController.submitForApproval()
  Input: 
    id = "ad-uuid-1234" (from URL parameter)
    submitDto = {
      approval_deadline: "2024-01-25T23:59:59Z",
      approval_comments: "Please review..."
    }
    request.user = { id: 1, role: {...} }
  ↓
  Calls: ClientAdsService.submitForApproval(id, submitDto, req)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: ClientAdsService.submitForApproval()
  Input: 
    id = "ad-uuid-1234"
    submitDto = { approval_deadline, approval_comments }
    req.user = { id: 1, role: {...} }
  ↓
  Step 1: Validate ad exists and user has permission
    ClientAdRepository.findById(id)
    Input: id = "ad-uuid-1234"
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - Ad Lookup                      │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT * FROM "client_ads"
         WHERE id = $1
    
    Input: id = "ad-uuid-1234"
    ↓
    Output: ClientAdEntity
    {
      id: "ad-uuid-1234",
      status: "Draft",
      approval_status: "Not Submitted",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      created_by: 1,
      ...
    }
    ↓
    Check permission: user can submit this ad
    If no permission → Throw Error: ForbiddenException
    If has permission → Continue
  ↓
  Step 2: Validate ad has client assigned
    if (!clientAd.client_id)
      → Throw Error: BadRequestException("Ad must have a client assigned before it can be submitted for approval")
    ↓
    If client_id exists → Continue
  ↓
  Step 3: Validate ad status is 'Draft'
    if (clientAd.status !== 'Draft')
      → Throw Error: BadRequestException("Cannot submit ad for approval. Current status is '${status}'. Only 'Draft' ads can be submitted.")
    ↓
    If status is 'Draft' → Continue
  ↓
  Step 4: Parse approval deadline if provided
    if (submitDto.approval_deadline) {
      approvalDeadline = new Date(submitDto.approval_deadline)
      if (isNaN(approvalDeadline.getTime()))
        → Throw Error: BadRequestException("Invalid approval deadline format")
    }
    ↓
    Output: approvalDeadline = Date("2024-01-25T23:59:59Z") OR undefined
  ↓
  Step 5: Update ad status
    clientAd.submitForApproval(approvalDeadline, submitDto.approval_comments)
    ↓
    Domain method updates:
      - status: "Draft" → "Pending Approval"
      - approval_status: "Not Submitted" → "Pending"
      - approval_deadline: approvalDeadline
      - approval_comments: submitDto.approval_comments
      - submitted_at: NOW()
    ↓
    ClientAdRepository.update(updatedAd)
    Input: Updated ClientAd domain object
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                  DATABASE QUERY - Ad Status Update                 │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: UPDATE "client_ads"
         SET "status" = 'Pending Approval',
             "approval_status" = 'Pending',
             "approval_deadline" = $1,
             "approval_comments" = $2,
             "submitted_at" = NOW(),
             "updated_at" = NOW()
         WHERE id = $3
         RETURNING *
    
    Input:
      approval_deadline = "2024-01-25T23:59:59Z"
      approval_comments = "Please review..."
      id = "ad-uuid-1234"
    ↓
    Output: Updated ClientAdEntity
    {
      id: "ad-uuid-1234",
      status: "Pending Approval",
      approval_status: "Pending",
      approval_deadline: "2024-01-25T23:59:59Z",
      approval_comments: "Please review...",
      submitted_at: "2024-01-15T10:40:00Z",
      updated_at: "2024-01-15T10:40:00Z",
      ...
    }
    ↓
    Returns: Updated ClientAdEntity
  ↓
  Step 6: Create activity log
    AdActivityService.create({
      ad_id: "ad-uuid-1234",
      type: "submitted_for_approval",
      description: "Ad submitted for approval",
      user_id: 1
    })
    ↓
    SQL: INSERT INTO "ad_activities" 
         ("ad_id", "type", "description", "user_id", "timestamp")
         VALUES ($1, $2, $3, $4, NOW())
  ↓
  Step 7: Create notification for client (if notify_client is true)
    AdNotificationService.create({
      ad_id: "ad-uuid-1234",
      user_id: client.user_id,
      type: "approval_requested",
      message: "New ad submitted for your approval",
      read: false
    })
    ↓
    SQL: INSERT INTO "ad_notifications"
         ("ad_id", "user_id", "type", "message", "read", "created_at")
         VALUES ($1, $2, $3, $4, false, NOW())
  ↓
  Returns: SubmitApprovalResponseDto
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      status: "Pending Approval",
      approval_status: "Pending",
      approval_deadline: "2024-01-25T23:59:59Z",
      approval_comments: "Please review...",
      submitted_at: "2024-01-15T10:40:00Z",
      submitted_by: 1
    }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: ClientAdsController.submitForApproval()
  Returns: SubmitApprovalResponseDto (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      status: "Pending Approval",
      approval_status: "Pending",
      ...
    }
  }
  ↓
Frontend Actions:
  1. Show success notification: "Ad submitted for approval successfully"
  2. Update ad status in UI: "Pending Approval"
  3. Disable edit actions (ad is now locked for editing)
  4. Show approval deadline countdown (if provided)
  5. Client receives notification (if enabled)
  ↓
Ad is now pending client approval
```

### Backend API

**Endpoint:** POST `/api/v1/client-ads/{id}/submit-for-approval`

**Request:**
```json
{
  "approval_deadline": "2024-01-25T23:59:59Z",
  "approval_comments": "Please review the campaign details and approve if everything looks good."
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "id": "ad-uuid-1234",
    "status": "Pending Approval",
    "approval_status": "Pending",
    "approval_deadline": "2024-01-25T23:59:59Z",
    "approval_comments": "Please review...",
    "submitted_at": "2024-01-15T10:40:00Z",
    "submitted_by": 1
  }
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "error": {
    "code": "BAD_REQUEST",
    "message": "Ad must have a client assigned before it can be submitted for approval"
  }
}
```

---

## 5. Client Approve/Reject Ad

### What User Sees

**Client User Experience:**
- Client navigates to pending approvals page (or receives notification)
- Client sees list of ads with status "Pending Approval"
- Each ad shows:
  - Campaign name
  - Ad preview/image
  - Approval deadline
  - Submitted date
  - "Approve" button (green)
  - "Reject" button (red/orange)

**Client Clicks on Ad:**
- Ad detail page opens
- Shows full ad preview
- Shows ad details (title, description, campaign info)
- Shows comments/notes from creator
- "Approve" and "Reject" buttons visible

### User Actions Available

1. **Click "Approve" button** → Open approval modal
2. **Click "Reject" button** → Open rejection modal
3. **Fill approval/rejection form** → Add comments
4. **Click "Confirm"** → Submit decision

### User Flow Diagram - Approve

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Client Approval Flow (Approve)                      │
└─────────────────────────────────────────────────────────────────────────────┘

Client Action:
  ↓
Client navigates to pending approvals page
  URL: /clients/approvals (or similar)
  ↓
Frontend fetches pending approvals:
  API Call: GET /api/v1/client-ads/pending-approvals
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Fetch Pending Approvals                 │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/client-ads/pending-approvals
  ↓
  Controller: ClientAdsController.getPendingApprovals()
  ↓
  Service: ClientAdsService.getPendingApprovals(req)
  ↓
  Database Query:
    SQL: SELECT * FROM "client_ads"
         WHERE "approval_status" = 'Pending'
         AND "client_id" IN (SELECT id FROM "client" WHERE "user_id" = $1)
         ORDER BY "submitted_at" DESC
  ↓
  Returns: List of ads
  ↓
Frontend receives Response:
  [
    {
      id: "ad-uuid-1234",
      campaign_name: "Summer Sale Campaign 2024",
      status: "Pending Approval",
      approval_deadline: "2024-01-25T23:59:59Z",
      ad_image_url: "https://...",
      ...
    },
    ...
  ]
  ↓
Frontend displays:
  - List of pending ads
  - Each ad shows preview, campaign name, deadline
  - "Approve" and "Reject" buttons on each ad
  ↓
Client clicks on ad to review
  ↓
Frontend: Navigate to ad detail page or open modal
  ↓
Client sees:
  - Full ad preview/image
  - Campaign details
  - Ad title and description
  - Comments from creator
  - Approval deadline countdown
  ↓
Client clicks "Approve" button
  ↓
Frontend: Open approval modal
  ↓
Client sees approval modal with form:
  - Comments: Text area (optional)
  - Notify Creator: Checkbox (default: checked)
  - "Confirm Approve" button
  ↓
Client fills form:
  - Comments: "Campaign looks great! Approved for launch."
  - Notify Creator: checked
  ↓
Client clicks "Confirm Approve" button
  ↓
Frontend Validation:
  - Check user is client owner of this ad
  ↓
Data Prepared:
  {
    decision: "Approved",
    comments: "Campaign looks great! Approved for launch.",
    notify_creator: true
  }
  ↓
API Call: POST /api/v1/client-ads/ad-uuid-1234/approve
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: { decision: "Approved", comments, notify_creator }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/client-ads/:id/approve
  ↓
Guard: @UseGuards(AuthGuard('jwt'))
  ↓
Controller: ClientAdsController.approve()
  Input: 
    id = "ad-uuid-1234" (from URL parameter)
    approveDto = {
      decision: "Approved",
      comments: "Campaign looks great! Approved for launch.",
      notify_creator: true
    }
    request.user = { id: 2, role: { id: 4, name: "Client" } }
  ↓
  Calls: ClientAdsService.approve(id, approveDto, req)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: ClientAdsService.approve()
  Input: 
    id = "ad-uuid-1234"
    approveDto = { decision: "Approved", comments, notify_creator }
    req.user = { id: 2, role: { id: 4, name: "Client" } }
  ↓
  Step 1: Validate ad exists
    ClientAdRepository.findById(id)
    Input: id = "ad-uuid-1234"
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                    DATABASE QUERY - Ad Lookup                      │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: SELECT * FROM "client_ads"
         WHERE id = $1
    
    Input: id = "ad-uuid-1234"
    ↓
    Output: ClientAdEntity
    {
      id: "ad-uuid-1234",
      status: "Pending Approval",
      approval_status: "Pending",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      created_by: 1,
      ...
    }
    ↓
    If null → Throw Error: NotFoundException
    If found → Continue
  ↓
  Step 2: Validate user is the client owner
    if (clientAd.client_id !== clientId from user)
      → Throw Error: ForbiddenException("You can only approve ads for your own client account")
    ↓
    If user is client owner → Continue
  ↓
  Step 3: Validate ad status is 'Pending Approval'
    if (clientAd.status !== 'Pending Approval')
      → Throw Error: BadRequestException("Ad is not pending approval")
    ↓
    If status is 'Pending Approval' → Continue
  ↓
  Step 4: Validate decision
    if (!['Approved', 'Rejected'].includes(approveDto.decision))
      → Throw Error: BadRequestException("Invalid decision. Must be 'Approved' or 'Rejected'")
    ↓
    If valid → Continue
  ↓
  Step 5: Update ad status based on decision
    if (approveDto.decision === "Approved") {
      clientAd.approve(req.user.id, approveDto.comments)
      ↓
      Domain method updates:
        - status: "Pending Approval" → "Approved"
        - approval_status: "Pending" → "Approved"
        - approved_by: req.user.id (2)
        - approved_at: NOW()
        - approval_comments: approveDto.comments
    }
    ↓
    ClientAdRepository.update(updatedAd)
    Input: Updated ClientAd domain object
    ↓
    ┌─────────────────────────────────────────────────────────────────────┐
    │                  DATABASE QUERY - Approval Update                   │
    └─────────────────────────────────────────────────────────────────────┘
    
    SQL: UPDATE "client_ads"
         SET "status" = 'Approved',
             "approval_status" = 'Approved',
             "approved_by" = $1,
             "approved_at" = NOW(),
             "approval_comments" = $2,
             "updated_at" = NOW()
         WHERE id = $3
         RETURNING *
    
    Input:
      approved_by = 2
      approval_comments = "Campaign looks great! Approved for launch."
      id = "ad-uuid-1234"
    ↓
    Output: Updated ClientAdEntity
    {
      id: "ad-uuid-1234",
      status: "Approved",
      approval_status: "Approved",
      approved_by: 2,
      approved_at: "2024-01-16T14:30:00Z",
      approval_comments: "Campaign looks great! Approved for launch.",
      updated_at: "2024-01-16T14:30:00Z",
      ...
    }
    ↓
    Returns: Updated ClientAdEntity
  ↓
  Step 6: Create activity log
    AdActivityService.create({
      ad_id: "ad-uuid-1234",
      type: "ad_approved",
      description: "Ad approved by client",
      user_id: 2
    })
    ↓
    SQL: INSERT INTO "ad_activities"
         ("ad_id", "type", "description", "user_id", "timestamp")
         VALUES ($1, $2, $3, $4, NOW())
  ↓
  Step 7: Create notification for creator (if notify_creator is true)
    if (approveDto.notify_creator) {
      AdNotificationService.create({
        ad_id: "ad-uuid-1234",
        user_id: clientAd.created_by,  // 1
        type: "ad_approved",
        message: "Your ad has been approved",
        read: false
      })
      ↓
      SQL: INSERT INTO "ad_notifications"
           ("ad_id", "user_id", "type", "message", "read", "created_at")
           VALUES ($1, $2, $3, $4, false, NOW())
    }
  ↓
  Returns: ApproveResponseDto
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      status: "Approved",
      approval_status: "Approved",
      approved_by: 2,
      approved_at: "2024-01-16T14:30:00Z",
      approval_comments: "Campaign looks great! Approved for launch."
    }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: ClientAdsController.approve()
  Returns: ApproveResponseDto (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      status: "Approved",
      approval_status: "Approved",
      ...
    }
  }
  ↓
Frontend Actions:
  1. Show success notification: "Ad approved successfully"
  2. Update ad status in UI: "Approved"
  3. Remove ad from pending approvals list
  4. Creator receives notification (if enabled)
  5. Ad can now be published/live
  ↓
Ad is approved and ready for launch
```

### User Flow Diagram - Reject

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Client Approval Flow (Reject)                       │
└─────────────────────────────────────────────────────────────────────────────┘

Client Action:
  ↓
Client is on ad detail page (from pending approvals)
  ↓
Client reviews ad:
  - Sees ad preview/image
  - Reads campaign details
  - Reviews comments from creator
  ↓
Client decides to reject the ad
  ↓
Client clicks "Reject" button
  ↓
Frontend: Open rejection modal
  ↓
Client sees rejection modal with form:
  - Comments: Text area (required for rejection)
  - Notify Creator: Checkbox (default: checked)
  - "Confirm Reject" button
  ↓
Client fills form:
  - Comments: "Please revise the messaging and colors."
  - Notify Creator: checked
  ↓
Frontend Validation:
  - Comments required (cannot be empty for rejection)
  - Check user is client owner of this ad
  ↓
Client clicks "Confirm Reject" button
  ↓
Data Prepared:
  {
    decision: "Rejected",
    comments: "Please revise the messaging and colors.",
    notify_creator: true
  }
  ↓
API Call: POST /api/v1/client-ads/ad-uuid-1234/approve
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: { decision: "Rejected", comments, notify_creator }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: ClientAdsService.approve()
  (Same flow as Approve, but with decision = "Rejected")
  ↓
  Step 5: Update ad status based on decision
    if (approveDto.decision === "Rejected") {
      clientAd.reject(req.user.id, approveDto.comments)
      ↓
      Domain method updates:
        - status: "Pending Approval" → "Rejected"
        - approval_status: "Pending" → "Rejected"
        - approved_by: req.user.id (2)
        - approved_at: NOW()
        - approval_comments: approveDto.comments
    }
    ↓
    SQL: UPDATE "client_ads"
         SET "status" = 'Rejected',
             "approval_status" = 'Rejected',
             "approved_by" = $1,
             "approved_at" = NOW(),
             "approval_comments" = $2,
             "updated_at" = NOW()
         WHERE id = $3
    ↓
    Output: Updated ClientAdEntity with status = "Rejected"
  ↓
  Step 6: Create activity log
    AdActivityService.create({
      ad_id: "ad-uuid-1234",
      type: "ad_rejected",
      description: "Ad rejected by client",
      user_id: 2
    })
  ↓
  Step 7: Create notification for creator
    AdNotificationService.create({
      ad_id: "ad-uuid-1234",
      user_id: clientAd.created_by,
      type: "ad_rejected",
      message: "Your ad has been rejected",
      read: false
    })
  ↓
  Returns: ApproveResponseDto
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      status: "Rejected",
      approval_status: "Rejected",
      approved_by: 2,
      approved_at: "2024-01-16T14:30:00Z",
      approval_comments: "Please revise the messaging and colors."
    }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      status: "Rejected",
      ...
    }
  }
  ↓
Frontend Actions:
  1. Show notification: "Ad rejected"
  2. Update ad status in UI: "Rejected"
  3. Remove ad from pending approvals list
  4. Creator receives notification with rejection comments
  5. Creator can revise ad and resubmit
  ↓
Ad is rejected and needs revision
```

### Backend API

**Endpoint:** POST `/api/v1/client-ads/{id}/approve`

**Request (Approve):**
```json
{
  "decision": "Approved",
  "comments": "Campaign looks great! Approved for launch.",
  "notify_creator": true
}
```

**Request (Reject):**
```json
{
  "decision": "Rejected",
  "comments": "Please revise the messaging and colors.",
  "notify_creator": true
}
```

**Response (Success - Approve):**
```json
{
  "success": true,
  "data": {
    "id": "ad-uuid-1234",
    "status": "Approved",
    "approval_status": "Approved",
    "approved_by": 2,
    "approved_at": "2024-01-16T14:30:00Z",
    "approval_comments": "Campaign looks great! Approved for launch."
  }
}
```

**Response (Success - Reject):**
```json
{
  "success": true,
  "data": {
    "id": "ad-uuid-1234",
    "status": "Rejected",
    "approval_status": "Rejected",
    "approved_by": 2,
    "approved_at": "2024-01-16T14:30:00Z",
    "approval_comments": "Please revise the messaging and colors."
  }
}
```

---

## 6. Assign Client to Ad

### What User Sees

**Scenario:** User has created an ad without assigning a client, or needs to change the client assignment.

**From Ad Detail Page (`/create/templates/{adId}`):**
- Ad status: "Draft" or "Rejected"
- Client field shows "No Client Assigned" or current client name
- "Assign Client" button or dropdown visible

### User Actions Available

1. **Click "Assign Client"** → Open client selection modal/dropdown
2. **Select client from list** → Choose client to assign
3. **Click "Save"** → Assign client to ad

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Assign Client Flow                                   │
└─────────────────────────────────────────────────────────────────────────────┘

User is on ad detail page:
  URL: /create/templates/{adId}
  Ad status: "Draft"
  Client: Not assigned
  ↓
User clicks "Assign Client" button
  ↓
Frontend: Open client selection modal/dropdown
  ↓
Frontend fetches available clients:
  API Call: GET /api/v1/clients
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
Frontend displays:
  - List of available clients
  - Each client shows: Name, Email, Status
  ↓
User selects a client:
  Example: "Client XYZ" (id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08")
  ↓
User clicks "Assign" or "Save"
  ↓
Frontend: assignClient(adId, clientId)
  Input:
    adId = "ad-uuid-1234"
    clientId = "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
  ↓
API Call: POST /api/v1/client-ads/ad-uuid-1234/assign-client
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: {
    client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/client-ads/:id/assign-client
  ↓
Guard: @UseGuards(AuthGuard('jwt'))
  ↓
Controller: ClientAdsController.assignClient()
  Input: 
    id = "ad-uuid-1234" (from URL parameter)
    assignClientDto = { client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08" }
    request.user = { id: 1, role: {...} }
  ↓
  Calls: ClientAdsService.assignClient(id, assignClientDto, req)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: ClientAdsService.assignClient()
  Input: 
    id = "ad-uuid-1234"
    assignClientDto = { client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08" }
    req.user = { id: 1, role: {...} }
  ↓
  Step 1: Validate ad exists
    ClientAdRepository.findById(id)
    ↓
    If null → Throw Error: NotFoundException
    If found → Continue
  ↓
  Step 2: Validate client exists
    ClientRepository.findById(assignClientDto.client_id)
    ↓
    SQL: SELECT * FROM "client"
         WHERE id = $1 AND "deletedAt" IS NULL
    ↓
    If null → Throw Error: NotFoundException("Client not found")
    If found → Continue
  ↓
  Step 3: Check user permissions
    - User must be creator of ad OR admin
    - If not → Throw Error: ForbiddenException
  ↓
  Step 4: Update ad with client_id
    clientAd.assignClient(assignClientDto.client_id)
    ↓
    Domain method updates:
      - client_id: null → "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
    ↓
    ClientAdRepository.update(updatedAd)
    ↓
    SQL: UPDATE "client_ads"
         SET "client_id" = $1,
             "updated_at" = NOW()
         WHERE id = $2
         RETURNING *
    ↓
    Output: Updated ClientAdEntity
  ↓
  Step 5: Create activity log
    AdActivityService.create({
      ad_id: "ad-uuid-1234",
      type: "client_assigned",
      description: "Client assigned to ad",
      user_id: 1
    })
  ↓
  Returns: AssignClientResponseDto
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      client: {
        id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
        name: "Client XYZ",
        email: "client@example.com"
      },
      updated_at: "2024-01-15T11:00:00Z"
    }
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Controller Response                            │
└─────────────────────────────────────────────────────────────────────────────┘

Controller: ClientAdsController.assignClient()
  Returns: AssignClientResponseDto (HTTP 200 OK)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FRONTEND - Response Handling                           │
└─────────────────────────────────────────────────────────────────────────────┘

Frontend receives Response:
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      client_id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      client: { name: "Client XYZ", ... }
    }
  }
  ↓
Frontend Actions:
  1. Show success notification: "Client assigned successfully"
  2. Update ad UI: Show client name
  3. Enable "Submit for Approval" button (if it was disabled)
  4. Close client selection modal
  ↓
Ad now has client assigned and can be submitted for approval
```

### Backend API

**Endpoint:** POST `/api/v1/client-ads/{id}/assign-client`

**Request:**
```json
{
  "client_id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08"
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "id": "ad-uuid-1234",
    "client_id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
    "client": {
      "id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
      "name": "Client XYZ",
      "email": "client@example.com"
    },
    "updated_at": "2024-01-15T11:00:00Z"
  }
}
```

**Response (Error - 404):**
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Client not found"
  }
}
```

---

## 7. Dashboard & Statistics

### What User Sees

**Page:** Dashboard (likely on `/create` or a dedicated dashboard page)

**Dashboard Widgets:**
- **Total Ads:** Count of all ads
- **Pending Approvals:** Number of ads waiting for approval
- **Overdue Approvals:** Number of ads past approval deadline
- **Approved This Week:** Count of ads approved in last 7 days
- **Rejected This Week:** Count of ads rejected in last 7 days
- **Status Distribution:** Chart showing ads by status (Draft, Pending Approval, Approved, Rejected, etc.)
- **Recent Activities:** Timeline of recent ad activities
- **Upcoming Deadlines:** List of ads with approaching approval deadlines

### User Actions Available

1. **View statistics** → See overview of all ad metrics
2. **Click on metric** → Filter/navigate to relevant ads
3. **View recent activities** → See timeline of actions
4. **View upcoming deadlines** → See ads needing attention

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Dashboard Statistics Loading                         │
└─────────────────────────────────────────────────────────────────────────────┘

User navigates to dashboard:
  URL: /create (or /create/dashboard)
  ↓
Frontend loads dashboard:
  API Call: GET /api/v1/client-ads/dashboard
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Dashboard Statistics                    │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/client-ads/dashboard
  ↓
  Controller: ClientAdsController.getDashboardStats()
  ↓
  Service: ClientAdsService.getDashboardStats(req)
  ↓
  Database Queries:
    - Total ads count (filtered by user role)
    - Pending approvals count
    - Overdue approvals count (approval_deadline < NOW())
    - Approved this week count (approved_at > 7 days ago)
    - Rejected this week count
    - Status distribution (GROUP BY status)
    - Recent activities (last 10 activities)
    - Upcoming deadlines (approval_deadline in next 7 days)
  ↓
  Returns: DashboardResponseDto
  {
    success: true,
    data: {
      total_ads: 150,
      pending_approvals: 15,
      overdue_approvals: 3,
      approved_this_week: 8,
      rejected_this_week: 2,
      status_distribution: [
        { status: "Draft", count: 25, percentage: 16.67 },
        { status: "Pending Approval", count: 15, percentage: 10.00 },
        { status: "Approved", count: 95, percentage: 63.33 },
        { status: "Rejected", count: 15, percentage: 10.00 }
      ],
      recent_activities: [
        {
          id: "activity-uuid-1",
          activity_type: "ad_created",
          description: "New ad created for Client XYZ",
          ad_name: "Summer Sale Campaign 2024",
          user_name: "John Doe",
          created_at: "2024-01-15T10:30:00Z"
        },
        ...
      ],
      upcoming_deadlines: [
        {
          ad_id: "ad-uuid-1234",
          campaign_name: "Summer Sale Campaign 2024",
          approval_deadline: "2024-01-25T23:59:59Z",
          days_remaining: 4
        },
        ...
      ]
    }
  }
  ↓
Frontend receives Response:
  Dashboard statistics
  ↓
Frontend displays:
  - Statistics cards/widgets
  - Status distribution chart
  - Recent activities timeline
  - Upcoming deadlines list
  ↓
User sees comprehensive dashboard overview
  ↓
User Actions:
  - Click on "Pending Approvals" → Navigate to Design Review filtered by status
  - Click on "Overdue Approvals" → Navigate to overdue ads
  - Click on activity → Navigate to ad detail page
  - Click on deadline → Navigate to ad detail page
```

### Backend API

**Endpoint:** GET `/api/v1/client-ads/dashboard`

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "total_ads": 150,
    "pending_approvals": 15,
    "overdue_approvals": 3,
    "approved_this_week": 8,
    "rejected_this_week": 2,
    "status_distribution": [
      {
        "status": "Draft",
        "count": 25,
        "percentage": 16.67
      },
      {
        "status": "Pending Approval",
        "count": 15,
        "percentage": 10.00
      },
      {
        "status": "Approved",
        "count": 95,
        "percentage": 63.33
      },
      {
        "status": "Rejected",
        "count": 15,
        "percentage": 10.00
      }
    ],
    "recent_activities": [
      {
        "id": "activity-uuid-1",
        "activity_type": "ad_created",
        "description": "New ad created for Client XYZ",
        "ad_name": "Summer Sale Campaign 2024",
        "user_name": "John Doe",
        "created_at": "2024-01-15T10:30:00Z"
      }
    ],
    "upcoming_deadlines": [
      {
        "ad_id": "ad-uuid-1234",
        "campaign_name": "Summer Sale Campaign 2024",
        "approval_deadline": "2024-01-25T23:59:59Z",
        "days_remaining": 4
      }
    ]
  }
}
```

**Note:** Statistics are filtered based on user role:
- **Admin/SuperAdmin:** See all ads statistics
- **Regular Users:** See only their own ads statistics
- **Clients:** See only ads assigned to their client account

---

## 8. Comments & Collaboration System

### What User Sees

**From Ad Detail Page (`/create/templates/{adId}`):**
- **Comments Section:**
  - List of comments (threaded/replies)
  - Each comment shows:
    - User name and avatar
    - Comment content
    - Timestamp
    - Resolved/Unresolved status (if applicable)
    - Attachments (if any)
    - Reply button
  - "Add Comment" input field
  - "Resolve" button on comments (if user has permission)

### User Actions Available

1. **View comments** → See all comments and replies
2. **Add comment** → Post new comment or reply
3. **Upload attachment** → Attach file to comment
4. **Resolve comment** → Mark comment as resolved
5. **Filter comments** → Filter by resolved/unresolved status

### User Flow Diagram - Add Comment

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Add Comment Flow                                    │
└─────────────────────────────────────────────────────────────────────────────┘

User is on ad detail page:
  URL: /create/templates/{adId}
  ↓
User scrolls to comments section
  ↓
User types comment in "Add Comment" field:
  Content: "Please review the color scheme. The blue might be too bright."
  Comment Type: "feedback" (optional)
  Parent Comment ID: null (for new comment) OR "comment-uuid" (for reply)
  ↓
User clicks "Post Comment" or "Send"
  ↓
Frontend: addComment(adId, commentData)
  Input:
    adId = "ad-uuid-1234"
    commentData = {
      content: "Please review the color scheme...",
      comment_type: "feedback",
      parent_comment_id: null
    }
  ↓
API Call: POST /api/v1/client-ads/ad-uuid-1234/comments
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "application/json"
  }
  Body: {
    content: "Please review the color scheme...",
    comment_type: "feedback",
    parent_comment_id: null
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND - Route Handler                            │
└─────────────────────────────────────────────────────────────────────────────┘

Route: POST /api/v1/client-ads/:id/comments
  ↓
Controller: ClientAdsController.addComment()
  Input: 
    id = "ad-uuid-1234"
    addCommentDto = {
      content: "Please review the color scheme...",
      comment_type: "feedback",
      parent_comment_id: null
    }
    request.user = { id: 1, role: {...} }
  ↓
  Calls: ClientAdsService.addComment(id, addCommentDto, req)
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Business Logic Service                         │
└─────────────────────────────────────────────────────────────────────────────┘

Service: ClientAdsService.addComment()
  Step 1: Validate ad exists
    ClientAdRepository.findById(id)
    ↓
    If null → Throw Error: NotFoundException
  ↓
  Step 2: Validate user has permission
    - User must be creator, client owner, or admin
    - If not → Throw Error: ForbiddenException
  ↓
  Step 3: Validate parent comment (if reply)
    if (addCommentDto.parent_comment_id) {
      CommentRepository.findById(parent_comment_id)
      ↓
      If null → Throw Error: NotFoundException("Parent comment not found")
    }
  ↓
  Step 4: Create comment
    CommentRepository.save({
      ad_id: "ad-uuid-1234",
      user_id: 1,
      content: "Please review the color scheme...",
      comment_type: "feedback",
      parent_comment_id: null,
      resolved: false
    })
    ↓
    SQL: INSERT INTO "ad_comments"
         ("ad_id", "user_id", "content", "comment_type", "parent_comment_id", "resolved", "created_at")
         VALUES ($1, $2, $3, $4, $5, false, NOW())
         RETURNING *
    ↓
    Output: CommentEntity
  ↓
  Step 5: Create activity log
    AdActivityService.create({
      ad_id: "ad-uuid-1234",
      type: "comment_added",
      description: "Comment added",
      user_id: 1
    })
  ↓
  Step 6: Create notification (if mentioned users or if reply)
    - If comment mentions users → Create notifications
    - If reply → Notify parent comment author
  ↓
  Returns: AddCommentResponseDto
  {
    success: true,
    data: {
      id: "comment-uuid-1234",
      ad_id: "ad-uuid-1234",
      user_id: 1,
      user: {
        id: 1,
        name: "John Doe",
        email: "john@example.com"
      },
      content: "Please review the color scheme...",
      comment_type: "feedback",
      parent_comment_id: null,
      resolved: false,
      created_at: "2024-01-15T12:00:00Z",
      updated_at: "2024-01-15T12:00:00Z"
    }
  }
  ↓
Frontend receives Response:
  New comment data
  ↓
Frontend Actions:
  1. Add comment to comments list
  2. Clear comment input field
  3. Scroll to new comment
  4. Show success notification (optional)
  ↓
Comment is added and visible to all users
```

### User Flow Diagram - Upload Comment Attachment

```
User adds comment with attachment:
  ↓
User clicks "Attach File" button
  ↓
Frontend: Open file picker
  ↓
User selects file (image, PDF, etc.)
  ↓
Frontend: Upload file first
  API Call: POST /api/v1/client-ads/comments/{commentId}/upload-attachment
  Headers: {
    "Authorization": "Bearer <accessToken>",
    "Content-Type": "multipart/form-data"
  }
  Form Data:
    - file: [selected file]
  ↓
Backend uploads to Azure Blob Storage
  ↓
Returns: Attachment URL
  ↓
Frontend: Add attachment URL to comment
  ↓
Continue with comment creation flow
```

### User Flow Diagram - Resolve Comment

```
User clicks "Resolve" button on comment
  ↓
Frontend: Open resolve modal (optional)
  ↓
User adds resolution note (optional):
  Resolution Note: "Color scheme updated as requested"
  ↓
User clicks "Mark as Resolved"
  ↓
API Call: PUT /api/v1/client-ads/comments/{commentId}/resolve
  Body: {
    resolved: true,
    resolution_note: "Color scheme updated as requested"
  }
  ↓
Backend updates comment:
  SQL: UPDATE "ad_comments"
       SET "resolved" = true,
           "resolution_note" = $1,
           "updated_at" = NOW()
       WHERE id = $2
  ↓
Returns: Updated comment
  ↓
Frontend: Update comment UI to show resolved status
```

### Backend API

**Endpoint:** GET `/api/v1/client-ads/{id}/comments`

**Query Parameters:**
- `resolved`: boolean (optional) - Filter by resolved status
- `page`: number (optional) - Page number
- `limit`: number (optional) - Items per page

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "comments": [
      {
        "id": "comment-uuid-1",
        "ad_id": "ad-uuid-1234",
        "user_id": 1,
        "user": {
          "id": 1,
          "name": "John Doe",
          "email": "john@example.com"
        },
        "content": "Please review the color scheme...",
        "comment_type": "feedback",
        "parent_comment_id": null,
        "resolved": false,
        "replies": [
          {
            "id": "comment-uuid-2",
            "content": "I'll update the colors.",
            "user": { "name": "Jane Smith" },
            "created_at": "2024-01-15T12:30:00Z"
          }
        ],
        "attachments": [],
        "created_at": "2024-01-15T12:00:00Z",
        "updated_at": "2024-01-15T12:00:00Z"
      }
    ],
    "total": 5,
    "page": 1,
    "limit": 10
  }
}
```

**Endpoint:** POST `/api/v1/client-ads/{id}/comments`

**Request:**
```json
{
  "content": "Please review the color scheme. The blue might be too bright.",
  "comment_type": "feedback",
  "parent_comment_id": null
}
```

**Endpoint:** PUT `/api/v1/client-ads/comments/{commentId}/resolve`

**Request:**
```json
{
  "resolved": true,
  "resolution_note": "Color scheme updated as requested"
}
```

**Endpoint:** POST `/api/v1/client-ads/comments/{commentId}/upload-attachment`

**Request:** `multipart/form-data`
- `file`: File (image, PDF, etc.)

---

## 9. Revising Rejected Ads

### What User Sees

**From Ad Detail Page (`/create/templates/{adId}`):**
- Ad status: "Rejected"
- Rejection comments visible from client
- "Edit" or "Revise" button enabled
- "Resubmit for Approval" button (after editing)

### User Actions Available

1. **Click "Edit" or "Revise"** → Open editor to modify ad
2. **Edit ad details** → Update campaign information
3. **Edit ad design** → Modify design based on feedback
4. **Click "Resubmit for Approval"** → Submit revised ad for approval

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Revise Rejected Ad Flow                             │
└─────────────────────────────────────────────────────────────────────────────┘

User is on ad detail page:
  URL: /create/templates/{adId}
  Ad status: "Rejected"
  ↓
User sees rejection feedback:
  - Rejection comments: "Please revise the messaging and colors."
  - Rejected by: Client Name
  - Rejected at: "2024-01-16T14:30:00Z"
  ↓
User clicks "Edit" or "Revise" button
  ↓
Option 1: Edit Ad Details Only
  Frontend: Open edit form
  ↓
  User updates:
    - Ad Title: "Summer Sale - 30% Off" (changed from "50% Off")
    - Ad Description: "Amazing summer deals with reasonable discounts"
    - Other campaign details
  ↓
  User clicks "Save Changes"
  ↓
  API Call: PUT /api/v1/client-ads/{adId}
  Body: {
    ad_title: "Summer Sale - 30% Off",
    ad_description: "Amazing summer deals with reasonable discounts",
    ...
  }
  ↓
  Backend updates ad:
    - Status remains "Rejected" (or changes to "Draft" based on implementation)
    - Updated fields saved
  ↓
  Frontend: Show success, update UI

Option 2: Edit Ad Design
  Frontend: Navigate to Polotno editor
  URL: /create/template-custom-editor/{adId}
  Example: /create/template-custom-editor/709a5ab0-ea34-42ce-87c9-31cee23096c1
  ↓
  Polotno editor loads existing ad design (from json_url)
  ↓
  User modifies design:
    - Changes colors (as per feedback)
    - Updates messaging
    - Adjusts layout
  ↓
  User clicks "Save" in editor
  ↓
  Frontend: Save updated design
    API Call: POST /api/v1/client-ads/{adId}/upload-json
    Body: { file: updated_json_data }
  ↓
  Backend uploads new JSON to Azure
  ↓
  Updates ad.json_url
  ↓
  Frontend: Navigate back to ad detail page

After editing (either details or design):
  ↓
User reviews changes
  ↓
User clicks "Resubmit for Approval" button
  ↓
Frontend: Open resubmission modal
  ↓
User sees modal with:
  - Approval Deadline: Date picker (optional)
  - Comments: Text area
    Pre-filled: "Ad revised based on feedback. Please review the updated version."
  - Notify Client: Checkbox (default: checked)
  ↓
User fills form:
  - Comments: "Ad revised based on feedback. Please review the updated version."
  - Notify Client: checked
  ↓
User clicks "Resubmit"
  ↓
Frontend: submitForApproval(adId, submitData)
  ↓
API Call: POST /api/v1/client-ads/{adId}/submit-for-approval
  Body: {
    approval_deadline: "2024-01-30T23:59:59Z",
    approval_comments: "Ad revised based on feedback. Please review the updated version."
  }
  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BACKEND - Resubmission Logic                             │
└─────────────────────────────────────────────────────────────────────────────┘

Service: ClientAdsService.submitForApproval()
  Step 1: Validate ad exists
  Step 2: Check current status
    - If status is "Rejected" → Allow resubmission
    - If status is "Draft" → Allow submission
    - If status is "Pending Approval" → Throw Error: "Ad already pending approval"
  ↓
  Step 3: Update ad status
    - status: "Rejected" → "Pending Approval"
    - approval_status: "Rejected" → "Pending"
    - Clear previous approval data (optional, or keep for history)
    - Set new approval_deadline
    - Set new approval_comments
    - submitted_at: NOW()
  ↓
  Step 4: Create activity log
    AdActivityService.create({
      ad_id: "ad-uuid-1234",
      type: "resubmitted_for_approval",
      description: "Ad revised and resubmitted for approval",
      user_id: 1
    })
  ↓
  Step 5: Create notification for client
    AdNotificationService.create({
      ad_id: "ad-uuid-1234",
      user_id: client.user_id,
      type: "approval_requested",
      message: "Ad has been revised and resubmitted for your approval",
      read: false
    })
  ↓
  Returns: SubmitApprovalResponseDto
  {
    success: true,
    data: {
      id: "ad-uuid-1234",
      status: "Pending Approval",
      approval_status: "Pending",
      approval_deadline: "2024-01-30T23:59:59Z",
      approval_comments: "Ad revised based on feedback...",
      submitted_at: "2024-01-20T10:00:00Z"
    }
  }
  ↓
Frontend receives Response:
  Updated ad with "Pending Approval" status
  ↓
Frontend Actions:
  1. Show success notification: "Ad revised and resubmitted for approval"
  2. Update ad status in UI: "Pending Approval"
  3. Client receives notification
  4. Ad appears in pending approvals list again
  ↓
Ad is resubmitted and waiting for client approval again
```

### Backend API

**Endpoint:** PUT `/api/v1/client-ads/{id}` (Update ad details)

**Request:**
```json
{
  "ad_title": "Summer Sale - 30% Off",
  "ad_description": "Amazing summer deals with reasonable discounts",
  "campaign_type": "social_media",
  "priority": "High"
}
```

**Endpoint:** POST `/api/v1/client-ads/{id}/upload-json` (Update design)

**Request:** `multipart/form-data`
- `file`: JSON file (updated design)

**Endpoint:** POST `/api/v1/client-ads/{id}/submit-for-approval` (Resubmit)

**Request:**
```json
{
  "approval_deadline": "2024-01-30T23:59:59Z",
  "approval_comments": "Ad revised based on feedback. Please review the updated version."
}
```

---

## 10. Client Pending Approvals View

### What User Sees

**For Client Users:**
- **Design Review Page (`/create/templates`)** - Same page as creators, but filtered view
- **Filtered View:**
  - Status filter: "Pending Approval" (default for clients)
  - Only shows ads assigned to their client account
  - Each ad shows:
    - Campaign name
    - Ad preview/image
    - Approval deadline
    - Days remaining
    - "Approve" and "Reject" buttons

**Alternative:** Clients might see pending approvals via:
- `GET /api/v1/client-ads/assigned-approvals` - Ads assigned to current user for approval
- `GET /api/v1/client-ads/assigned-ads` - All ads assigned to client (all statuses)

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Client Pending Approvals View                        │
└─────────────────────────────────────────────────────────────────────────────┘

Client User (Role: Client) navigates to:
  URL: /create/templates
  ↓
Frontend detects user role = Client
  ↓
Frontend automatically filters:
  - Status: "Pending Approval"
  - Client: Current user's client account
  ↓
Frontend fetches pending approvals:
  API Call: GET /api/v1/client-ads/assigned-approvals
  OR: GET /api/v1/client-ads?status=Pending Approval&client_id={clientId}
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Assigned Approvals                      │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/client-ads/assigned-approvals
  ↓
  Controller: ClientAdsController.getAssignedApprovals()
  ↓
  Service: ClientAdsService.getAssignedApprovals(req)
  ↓
  Database Query:
    SQL: SELECT ca.* FROM "client_ads" ca
         INNER JOIN "client" c ON ca."client_id" = c.id
         WHERE ca."approval_status" = 'Pending'
         AND (
           c."user_id" = $1
           OR c."approverEmail" = $2
           OR c."ownerEmail" = $2
           OR c."email" = $2
         )
         ORDER BY ca."submitted_at" DESC
  ↓
  Returns: List of pending ads for this client
  ↓
Frontend receives Response:
  [
    {
      id: "ad-uuid-1234",
      campaign_name: "Summer Sale Campaign 2024",
      status: "Pending Approval",
      approval_status: "Pending",
      approval_deadline: "2024-01-25T23:59:59Z",
      days_remaining: 5,
      ad_image_url: "https://...",
      client: {
        id: "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
        name: "Client XYZ"
      },
      ...
    },
    ...
  ]
  ↓
Frontend displays:
  - List of pending ads
  - Each ad card shows:
    - Thumbnail preview
    - Campaign name
    - Approval deadline countdown
    - "Approve" button (green)
    - "Reject" button (red)
  ↓
Client sees their pending approvals
  ↓
Client Actions:
  - Click on ad → Navigate to ad detail page
  - Click "Approve" → Open approval modal
  - Click "Reject" → Open rejection modal
  ↓
(Continues to Section 5: Client Approve/Reject Ad flow)
```

### Backend API

**Endpoint:** GET `/api/v1/client-ads/assigned-approvals`

**Query Parameters:**
- `page`: number (optional) - Page number
- `limit`: number (optional) - Items per page

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "ads": [
      {
        "id": "ad-uuid-1234",
        "campaign_name": "Summer Sale Campaign 2024",
        "ad_title": "Summer Sale - 50% Off Everything",
        "status": "Pending Approval",
        "approval_status": "Pending",
        "approval_deadline": "2024-01-25T23:59:59Z",
        "days_remaining": 5,
        "ad_image_url": "https://storage.azure.com/...",
        "client": {
          "id": "c22fb4df-7ed8-4201-9dd6-a168ccf8af08",
          "name": "Client XYZ"
        },
        "created_by": 1,
        "submitted_at": "2024-01-15T10:40:00Z"
      }
    ],
    "total": 3,
    "page": 1,
    "limit": 10
  }
}
```

**Endpoint:** GET `/api/v1/client-ads/assigned-ads`

**Purpose:** Get all ads assigned to client (all statuses, not just pending)

**Response:** Similar structure but includes ads with all statuses (Draft, Pending Approval, Approved, Rejected, etc.)

---

## 11. Notifications System

### What User Sees

**Notification Center/Bell Icon:**
- Notification count badge (unread count)
- Dropdown or page showing notifications
- Each notification shows:
  - Type (approval_requested, ad_approved, ad_rejected, comment_added, etc.)
  - Message
  - Ad name (clickable)
  - Timestamp
  - Read/Unread indicator
- "Mark all as read" button
- Filter options (All, Unread, By type)

### User Actions Available

1. **View notifications** → See all notifications
2. **Click notification** → Navigate to related ad
3. **Mark as read** → Mark individual notification as read
4. **Mark all as read** → Mark all notifications as read
5. **Filter notifications** → Filter by type or read status

### User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FRONTEND - Notifications Flow                                  │
└─────────────────────────────────────────────────────────────────────────────┘

User clicks notification bell icon
  ↓
Frontend fetches notifications:
  API Call: GET /api/v1/client-ads/notifications
  Query Params: { page: 1, limit: 20, read: null }
  Headers: { "Authorization": "Bearer <accessToken>" }
  ↓
  ┌─────────────────────────────────────────────────────────────────────┐
  │                    BACKEND - Get Notifications                        │
  └─────────────────────────────────────────────────────────────────────┘
  
  Route: GET /api/v1/client-ads/notifications
  ↓
  Controller: ClientAdsController.getNotifications()
  ↓
  Service: ClientAdsService.getNotifications(filters, req)
  ↓
  Database Query:
    SQL: SELECT * FROM "ad_notifications"
         WHERE "user_id" = $1
         AND (read = $2 OR $2 IS NULL)
         ORDER BY "created_at" DESC
         LIMIT $3 OFFSET $4
  ↓
  Returns: List of notifications
  [
    {
      id: "notification-uuid-1",
      ad_id: "ad-uuid-1234",
      type: "approval_requested",
      message: "New ad submitted for your approval",
      read: false,
      created_at: "2024-01-15T10:40:00Z",
      ad: {
        id: "ad-uuid-1234",
        campaign_name: "Summer Sale Campaign 2024"
      }
    },
    {
      id: "notification-uuid-2",
      ad_id: "ad-uuid-1234",
      type: "ad_approved",
      message: "Your ad has been approved",
      read: false,
      created_at: "2024-01-16T14:30:00Z",
      ad: {
        id: "ad-uuid-1234",
        campaign_name: "Summer Sale Campaign 2024"
      }
    },
    ...
  ]
  ↓
Frontend receives Response:
  List of notifications
  ↓
Frontend displays:
  - Notification dropdown/list
  - Unread count badge
  - Each notification with type, message, timestamp
  - Read/Unread indicators
  ↓
User sees notifications
  ↓
User Actions:
  Option 1: Click on notification
    → Navigate to: /create/templates/{adId}
    → Mark notification as read automatically
  Option 2: Click "Mark as Read" on notification
    → API Call: PUT /api/v1/client-ads/notifications/{notificationId}/read
    → Body: { is_read: true }
    → Backend updates notification
    → Frontend updates UI
  Option 3: Click "Mark All as Read"
    → Loop through unread notifications
    → Mark each as read
```

### Backend API

**Endpoint:** GET `/api/v1/client-ads/notifications`

**Query Parameters:**
- `page`: number (optional) - Page number
- `limit`: number (optional) - Items per page
- `read`: boolean (optional) - Filter by read status
- `type`: string (optional) - Filter by notification type

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notification-uuid-1",
        "ad_id": "ad-uuid-1234",
        "type": "approval_requested",
        "message": "New ad submitted for your approval",
        "read": false,
        "created_at": "2024-01-15T10:40:00Z",
        "ad": {
          "id": "ad-uuid-1234",
          "campaign_name": "Summer Sale Campaign 2024",
          "ad_title": "Summer Sale - 50% Off Everything"
        }
      },
      {
        "id": "notification-uuid-2",
        "ad_id": "ad-uuid-1234",
        "type": "ad_approved",
        "message": "Your ad has been approved",
        "read": false,
        "created_at": "2024-01-16T14:30:00Z",
        "ad": {
          "id": "ad-uuid-1234",
          "campaign_name": "Summer Sale Campaign 2024"
        }
      }
    ],
    "total": 15,
    "unread_count": 5,
    "page": 1,
    "limit": 20
  }
}
```

**Endpoint:** PUT `/api/v1/client-ads/notifications/{notificationId}/read`

**Request:**
```json
{
  "is_read": true
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "id": "notification-uuid-1",
    "read": true,
    "updated_at": "2024-01-20T10:00:00Z"
  }
}
```

### Notification Types

- `approval_requested` - Ad submitted for approval
- `ad_approved` - Ad approved by client
- `ad_rejected` - Ad rejected by client
- `comment_added` - New comment on ad
- `comment_replied` - Reply to user's comment
- `client_assigned` - Client assigned to ad
- `ad_created` - New ad created (for admins)

---

## 12. File Upload Flows

### Upload Ad Image

**Endpoint:** POST `/api/v1/client-ads/{id}/upload-image`

**Purpose:** Upload or update ad preview image

**Request:** `multipart/form-data`
- `file`: Image file (JPEG, PNG, GIF, WebP)
- `type`: string (optional) - "ad_image", "thumbnail", etc.

**Flow:**
```
User on ad detail page
  ↓
User clicks "Upload Image" or "Change Image"
  ↓
Frontend: Open file picker
  ↓
User selects image file
  ↓
Frontend: Validate file
  - Check file type (JPEG, PNG, GIF, WebP)
  - Check file size (< 10MB)
  ↓
Frontend: Upload file
  API Call: POST /api/v1/client-ads/{id}/upload-image
  Form Data:
    - file: [image file]
    - type: "ad_image"
  ↓
Backend:
  1. Validate file type and size
  2. Upload to Azure Blob Storage
  3. Get file URL
  4. Update ad.ad_image_url
  5. Return URL
  ↓
Frontend: Update ad preview with new image
```

**Response:**
```json
{
  "success": true,
  "data": {
    "ad_id": "ad-uuid-1234",
    "image_url": "https://storage.azure.com/container/client-ads/ad-uuid-1234/image.png",
    "type": "ad_image",
    "uploaded_at": "2024-01-15T11:00:00Z"
  }
}
```

### Upload JSON Configuration

**Endpoint:** POST `/api/v1/client-ads/{id}/upload-json`

**Purpose:** Upload or update ad design JSON (Polotno format)

**Request:** `multipart/form-data`
- `file`: JSON file
- `description`: string (optional) - Description of the JSON

**Flow:**
```
User in editor or ad detail page
  ↓
User saves design or uploads JSON
  ↓
Frontend: Prepare JSON data
  - Convert editor state to JSON
  - Or use existing JSON file
  ↓
Frontend: Upload JSON
  API Call: POST /api/v1/client-ads/{id}/upload-json
  Form Data:
    - file: [json file]
    - description: "Updated design with new colors"
  ↓
Backend:
  1. Validate JSON structure
  2. Upload to Azure Blob Storage
  3. Get file URL
  4. Update ad.json_url
  5. Return URL
  ↓
Frontend: Confirm upload success
```

**Response:**
```json
{
  "success": true,
  "data": {
    "ad_id": "ad-uuid-1234",
    "json_url": "https://storage.azure.com/container/client-ads/ad-uuid-1234/template.json",
    "description": "Updated design with new colors",
    "uploaded_at": "2024-01-15T11:00:00Z"
  }
}
```

---

## 13. Additional Client Pages

### Client Detail Page (`/create/clients/{id}`)

**Page URL:** `https://app.pixelplusai.com/create/clients/{id}`
**Example:** `https://app.pixelplusai.com/create/clients/5d4922f4-647d-4810-bdea-94b00800290b`

**Purpose:** Overview page for a specific client

**What User Sees:**
- Client information summary
- Tabs/Navigation to:
  - Customer Profile
  - Product Proposition
  - Branding
- Quick stats (number of ads, pending approvals, etc.)
- Recent ads for this client

### Customer Profile Page (`/create/clients/{id}/customer-profile`)

**Page URL:** `https://app.pixelplusai.com/create/clients/{id}/customer-profile`

**Purpose:** Manage customer profile information

**What User Sees:**
- Customer information form:
  - Company name
  - Industry
  - Contact information
  - Customer demographics
  - Customer preferences
  - Notes
- Save/Cancel buttons

### Product Proposition Page (`/create/clients/{id}/product-proposition`)

**Page URL:** `https://app.pixelplusai.com/create/clients/{id}/product-proposition`

**Purpose:** Manage product proposition and value statements

**What User Sees:**
- Product proposition form:
  - Value propositions
  - Key features
  - Unique selling points
  - Target market
  - Competitive advantages
  - Product descriptions
- Save/Cancel buttons

---

## 14. Edit Draft Ads Flow

### What User Sees

**From Ad Detail Page (`/create/templates/{adId}`):**
- Ad status: "Draft"
- "Edit" button enabled
- "Edit Design" button (if design exists)

### User Actions Available

1. **Click "Edit"** → Edit ad details (campaign info)
2. **Click "Edit Design"** → Open editor to modify design
3. **Save changes** → Update ad without submitting

### User Flow Diagram

```
User on ad detail page:
  URL: /create/templates/{adId}
  Ad status: "Draft"
  ↓
Option 1: Edit Ad Details
  User clicks "Edit" button
  ↓
  Frontend: Enable edit mode for form fields
  ↓
  User modifies:
    - Campaign name
    - Ad title
    - Ad description
    - Campaign type
    - Priority
    - Target audience
    - Budget
    - Deadline
  ↓
  User clicks "Save Changes"
  ↓
  API Call: PUT /api/v1/client-ads/{adId}
  Body: { updated fields }
  ↓
  Backend updates ad
  ↓
  Frontend: Show success, disable edit mode

Option 2: Edit Ad Design
  User clicks "Edit" icon/button
  ↓
  Frontend: Navigate to Polotno editor
  URL: /create/template-custom-editor/{adId}
  Example: /create/template-custom-editor/709a5ab0-ea34-42ce-87c9-31cee23096c1
  ↓
  Polotno editor loads:
    - If ad has json_url → Load existing design from json_url
    - If no json_url → Load original template (if template_id available)
  ↓
  User modifies design:
    - Change colors
    - Update text
    - Adjust layout
    - Add/remove elements
  ↓
  User clicks "Save" in editor
  ↓
  Frontend: Save design
    Option A: Save as new variant (keep original)
    Option B: Update existing design
  ↓
  If updating:
    API Call: POST /api/v1/client-ads/{adId}/upload-json
    Body: { file: updated_json }
  ↓
  Backend updates json_url
  ↓
  Frontend: Option to navigate back to ad detail
  ↓
  Ad remains in "Draft" status
  User can continue editing or submit later
```

---

## 6. Complete Database Schema

### Client Ads Table
```sql
CREATE TABLE "client_ads" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Campaign Information
  campaign_name VARCHAR(255) NOT NULL,
  client_id UUID REFERENCES "client"(id) ON DELETE CASCADE,
  created_by INTEGER REFERENCES "user"(id),
  
  -- Ad Content
  ad_title VARCHAR(500),
  ad_description TEXT,
  ad_image_url VARCHAR,
  json_url VARCHAR,
  
  -- Campaign Details
  campaign_type VARCHAR(100),
  target_audience TEXT,
  campaign_objectives TEXT,
  budget_range VARCHAR(100),
  
  -- Status and Workflow
  status VARCHAR(50) DEFAULT 'Draft',
  priority VARCHAR(20) DEFAULT 'Medium',
  
  -- Approval Data
  approval_status VARCHAR(50) DEFAULT 'Not Submitted',
  approval_deadline TIMESTAMP,
  approval_comments TEXT,
  approved_by INTEGER REFERENCES "user"(id),
  approved_at TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  submitted_at TIMESTAMP,
  
  -- Metadata
  tags TEXT[],
  metadata JSONB,
  
  CONSTRAINT "CHK_client_ads_status" CHECK (status IN ('Draft', 'Pending Approval', 'In Review', 'Approved', 'Rejected', 'Revise', 'Live', 'Completed')),
  CONSTRAINT "CHK_client_ads_priority" CHECK (priority IN ('High', 'Medium', 'Low')),
  CONSTRAINT "CHK_client_ads_approval_status" CHECK (approval_status IN ('Not Submitted', 'Pending', 'Approved', 'Rejected'))
);
```

### Ad Activities Table
```sql
CREATE TABLE "ad_activities" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ad_id UUID REFERENCES "client_ads"(id) ON DELETE CASCADE,
  type VARCHAR(100) NOT NULL,  -- 'ad_created', 'submitted_for_approval', 'ad_approved', 'ad_rejected', etc.
  description TEXT,
  user_id INTEGER REFERENCES "user"(id),
  timestamp TIMESTAMP DEFAULT NOW()
);
```

### Ad Comments Table
```sql
CREATE TABLE "ad_comments" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ad_id UUID REFERENCES "client_ads"(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES "user"(id),
  content TEXT NOT NULL,
  comment_type VARCHAR(50),  -- 'feedback', 'question', 'suggestion', etc.
  parent_comment_id UUID REFERENCES "ad_comments"(id),
  resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Ad Notifications Table
```sql
CREATE TABLE "ad_notifications" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ad_id UUID REFERENCES "client_ads"(id) ON DELETE SET NULL,
  user_id INTEGER REFERENCES "user"(id),
  type VARCHAR(50) NOT NULL,  -- 'approval_requested', 'ad_approved', 'ad_rejected', etc.
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Client Table
```sql
CREATE TABLE "client" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  user_id INTEGER REFERENCES "user"(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deletedAt TIMESTAMP
);
```

### Table Relationships

```
client (1) ────── (many) client_ads
  │
  └─────── (1) user

user (1) ────── (many) client_ads (created_by)
user (1) ────── (many) client_ads (approved_by)

client_ads (1) ────── (many) ad_activities
client_ads (1) ────── (many) ad_comments
client_ads (1) ────── (many) ad_notifications
```

---

## 7. Key Business Rules Summary

### Ad Status Flow
1. **Draft:**
   - Initial status when ad is created
   - Can be edited freely
   - Cannot be submitted without client assignment

2. **Pending Approval:**
   - Status after submission
   - Cannot be edited (locked)
   - Waiting for client decision

3. **Approved:**
   - Client approved the ad
   - Ready for launch/publishing
   - Can be moved to "Live" status

4. **Rejected:**
   - Client rejected the ad
   - Creator can revise and resubmit
   - Ad moves back to "Draft" when revised

### Approval Requirements
- Ad must have `client_id` assigned before submission
- Only ads with status "Draft" can be submitted
- Only the client owner can approve/reject their ads
- Approval deadline is optional but recommended

### Permission Rules
- **Creator:** Can create, edit (if Draft), submit for approval
- **Client:** Can view, approve/reject their own ads
- **Admin/SuperAdmin:** Can view all ads, manage any ad

### File Upload
- Images: JPEG, PNG, GIF, WebP
- Max file size: 10MB (configurable)
- Files stored in Azure Blob Storage
- URLs stored in database

### Notifications
- Created when ad is submitted for approval
- Created when ad is approved/rejected
- Can be marked as read
- Sent to relevant users (creator, client)

