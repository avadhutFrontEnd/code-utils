# Client Ads Flow Coverage Analysis

## ✅ COVERED FLOWS

### 1. Core Creation & Navigation Flows
- ✅ Landing on `/create` page
- ✅ Ad Maker Page (`/create/admaker`) - Template selection
- ✅ AdChat Editor Page (`/create/adchat?templateId=...`) - Template editing
- ✅ Save flow - Creates ad and auto-submits for approval
- ✅ Design Review Page (`/create/templates`) - View all ads
- ✅ Ad Detail/Edit Page (`/create/templates/{adId}`) - View/edit ad details

### 2. Client Management Flows
- ✅ Clients Management Page (`/create/clients`) - Manage clients
- ✅ Client Branding Page (`/create/clients/{clientId}/branding`) - Edit client branding

### 3. Approval Workflow
- ✅ Submit Ad for Approval flow
- ✅ Client Approve/Reject flow
- ✅ Rejection handling (mentioned but not detailed)

### 4. Backend API Coverage
- ✅ POST `/api/v1/client-ads` - Create ad
- ✅ GET `/api/v1/client-ads` - List ads
- ✅ GET `/api/v1/client-ads/{id}` - Get ad details
- ✅ POST `/api/v1/client-ads/{id}/submit-for-approval` - Submit for approval
- ✅ POST `/api/v1/client-ads/{id}/approve` - Approve/Reject ad

### 5. Database & Business Rules
- ✅ Complete Database Schema
- ✅ Business Rules Summary

---

## ❌ MISSING FLOWS (Not Documented)

### 1. **Assign Client Flow** ⚠️ IMPORTANT
- **Endpoint:** `POST /api/v1/client-ads/{id}/assign-client`
- **Purpose:** Assign a client to an ad after creation (if not assigned during creation)
- **Status:** Mentioned in API docs but no detailed flow in documentation
- **When Used:** When ad is created without client_id, or needs to change client

### 2. **Dashboard/Statistics Flow** ⚠️ IMPORTANT
- **Endpoint:** `GET /api/v1/client-ads/dashboard`
- **Purpose:** Get dashboard statistics (total ads, pending approvals, overdue, status distribution, recent activities, upcoming deadlines)
- **Status:** Not documented at all
- **UI Location:** Likely on `/create` or a dashboard page

### 3. **Assigned Approvals vs Pending Approvals** ⚠️ IMPORTANT
- **Endpoints:**
  - `GET /api/v1/client-ads/assigned-approvals` - Ads assigned to current user for approval
  - `GET /api/v1/client-ads/assigned-ads` - All ads assigned to client (all statuses)
  - `GET /api/v1/client-ads/pending-approvals` - Pending approvals (documented but unclear where clients see this)
- **Status:** Difference between these endpoints not clear
- **Client View:** Where do clients actually see pending approvals? Same `/create/templates` page or separate?

### 4. **Comments System** ⚠️ IMPORTANT
- **Endpoints:**
  - `GET /api/v1/client-ads/{id}/comments` - Get comments
  - `POST /api/v1/client-ads/{id}/comments` - Add comment
  - `PUT /api/v1/client-ads/comments/{commentId}/resolve` - Resolve comment
  - `POST /api/v1/client-ads/comments/{commentId}/upload-attachment` - Upload attachment to comment
- **Status:** Not documented at all
- **Features:** Threaded comments, mentions, attachments, resolution

### 5. **Notifications System** ⚠️ IMPORTANT
- **Endpoints:**
  - `GET /api/v1/client-ads/notifications` - Get notifications
  - `PUT /api/v1/client-ads/notifications/{notificationId}/read` - Mark as read
- **Status:** Mentioned but not detailed
- **Features:** Notification types, read/unread status

### 6. **Revising Rejected Ads Flow** ⚠️ IMPORTANT
- **Current Status:** Mentioned that creator can revise, but no detailed flow
- **Missing:**
  - How does creator edit a rejected ad?
  - Does status change from "Rejected" to "Draft" automatically?
  - How to resubmit after revision?
  - Can they edit the design or just details?

### 7. **File Upload Flows**
- **Endpoints:**
  - `POST /api/v1/client-ads/{id}/upload-image` - Upload ad image
  - `POST /api/v1/client-ads/{id}/upload-json` - Upload JSON configuration
- **Status:** Mentioned in save flow but not as separate detailed flows
- **When Used:** After ad creation, updating ad assets

### 8. **Update Template Flow**
- **Endpoint:** `PUT /api/v1/client-ads/:template_id/update-template`
- **Status:** Not documented
- **Purpose:** Update template configuration

### 9. **Additional Client Pages** ⚠️
- **Routes Found:**
  - `/create/clients/:id` - Client detail page (index)
  - `/create/clients/:id/customer-profile` - Customer profile
  - `/create/clients/:id/product-proposition` - Product proposition
- **Status:** Only branding page is documented
- **Missing:** Customer profile and product proposition pages

### 10. **Edit Draft Ads Flow**
- **Status:** Mentioned but not detailed
- **Missing:**
  - Can user go back to editor from ad detail page?
  - How to modify design of a Draft ad?
  - Can they change template?

### 11. **Save as Draft vs Auto-Submit**
- **Current:** "Save" button auto-submits for approval
- **Question:** Is there an option to save as Draft without submitting?
- **Missing:** Flow for saving as Draft and submitting later

---

## 🔍 UNCLEAR AREAS

1. **Client's View of Pending Approvals:**
   - Do clients see pending approvals on `/create/templates` (Design Review)?
   - Or is there a separate client-facing page?
   - How do they filter to see only their pending approvals?

2. **Status Transitions:**
   - What is "Revise" status? When is it used?
   - How does ad move from "Rejected" → "Draft" → "Pending Approval"?
   - What are "In Review", "Live", "Completed" statuses used for?

3. **Role-Based Views:**
   - How do views differ for Creator vs Client vs Admin?
   - What can each role see/do?

---

## 📋 RECOMMENDATIONS

### High Priority (Should Add):
1. **Assign Client Flow** - Common use case
2. **Dashboard/Statistics** - Important for overview
3. **Comments System** - Critical for collaboration
4. **Revising Rejected Ads** - Complete the approval cycle
5. **Client's Pending Approvals View** - Clarify where clients see approvals

### Medium Priority:
6. **Notifications System** - Detailed flow
7. **File Upload Flows** - Separate detailed flows
8. **Edit Draft Ads** - How to modify draft ads
9. **Additional Client Pages** - Customer profile, product proposition

### Low Priority:
10. **Update Template** - If used frequently
11. **Assigned Approvals vs Pending** - Clarify differences

---

## 📊 COVERAGE SUMMARY

- **Core Flows:** ✅ 90% Covered
- **API Endpoints:** ⚠️ 60% Covered (many endpoints not documented)
- **UI Pages:** ⚠️ 70% Covered (some client pages missing)
- **Collaboration Features:** ❌ 0% Covered (comments, notifications)
- **Edge Cases:** ⚠️ 30% Covered (revising, assigning client)

**Overall Coverage: ~65%**

