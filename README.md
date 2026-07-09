# GrowEasy CRM AI-Powered CSV Importer

An intelligent, AI-powered CSV lead importer that parses any valid CSV file (regardless of column layouts, header names, or structure) and extracts them into a normalized CRM format using the Google Gemini model.

It features a stunning, premium dark-themed dashboard frontend in Next.js, and a robust Node/Express backend that utilizes Server-Sent Events (SSE) to stream batch-by-batch AI mapping progress in real time.

---

## Key Features

1. **Flexible CSV Parsing**:
   - **Separator Agnostic**: Automatic detection of commas `,`, semicolons `;`, and tabs `\t`.
   - **Layout Independent**: Works with Facebook Ads, Google Ads, Real Estate CRMs, manually created sheets, or custom layouts. AI dynamically resolves messy, ambiguous headers (e.g., mapping `Cell`, `Contact Number`, `Phone No` all to `mobile_without_country_code`).
2. **Interactive Preview**:
   - Parses CSV client-side using `PapaParse` to display a beautiful sticky-header preview table with horizontal and vertical scrolling prior to committing the file.
3. **Advanced AI Mapping (Gemini 2.5 Flash)**:
   - Utilizes Google's modern `@google/genai` SDK.
   - Leverages **Structured Outputs (JSON Schema)** to guarantee output conformity and error-free formatting.
   - Cleanses date formats, normalizes country codes, and splits names/emails appropriately.
   - **Skip Invalid Leads**: Discards any lead lacking both email and phone number.
   - **Handling Duplicates**: Uses the first email/mobile and pushes subsequent numbers/emails to `crm_note`.
4. **SSE Real-time Streaming**:
   - Streams live batch-by-batch parsing progress, AI metrics, and status updates directly to the frontend.
5. **Interactive Dashboard**:
   - Visualizes imported and skipped leads in tabbed tables.
   - Exporter: Allows downloading the finalized leads as a normalized JSON or CSV file.
   - Includes a configuration panel to easily enter/change the Gemini API key in the UI.
6. **Docker Orchestrated**:
   - Fully dockerized backend and frontend with Docker Compose support.
7. **Robust Testing**:
   - Self-contained backend unit tests running validation on all parsing helper utilities.

---

## Project Structure

```text
.
├── backend/
│   ├── .env                    # Environment secrets
│   ├── .env.example            # Environment templates
│   ├── Dockerfile              # Docker image definition
│   ├── index.js                # Express Server entrypoint
│   ├── aiService.js            # Gemini AI integration service
│   ├── test.js                 # Unit tests
│   └── package.json            # Node dependencies
├── frontend/
│   ├── Dockerfile              # Docker image definition
│   ├── package.json            # Next.js dependencies
│   └── src/
│       ├── app/
│       │   ├── globals.css     # Premium Vanilla CSS design system
│       │   ├── layout.tsx      # Main layout
│       │   └── page.tsx        # Importer step coordinator
│       └── components/
│           ├── CsvUpload.tsx   # Drag & Drop file input
│           ├── CsvPreview.tsx  # Sticky header table preview
│           ├── ImportProgress.tsx # SSE streaming visualizer
│           └── ImportResults.tsx  # Extracted results & downloads
├── docker-compose.yml          # Container orchestrator
└── README.md                   # Project documentation
```

---

## Setup & Local Installation

### Prerequisites
- Node.js (v20+ recommended)
- npm (v10+ recommended)
- Google Gemini API Key (get it from [Google AI Studio](https://aistudio.google.com/))

### 1. Backend Setup
1. Open a terminal and navigate to the `backend/` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create your `.env` configuration file:
   ```bash
   cp .env.example .env
   ```
4. Edit the `.env` file to add your Google Gemini API key:
   ```env
   GEMINI_API_KEY=AIzaSy...
   ```
5. Launch the backend server in development mode:
   ```bash
   npm run dev
   ```
   The backend will run on `http://localhost:5000`.

### 2. Frontend Setup
1. In a new terminal, navigate to the `frontend/` directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the development server:
   ```bash
   npm run dev
   ```
   Open `http://localhost:3000` in your web browser.

---

## Running with Docker

You can spin up the entire stack using Docker Compose.

1. Ensure Docker is running on your system.
2. In the root directory, create a `.env` file (or pass it in the shell) containing your API key:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
3. Build and launch the containers:
   ```bash
   docker-compose up --build
   ```
4. Access the applications:
   - Frontend: `http://localhost:3000`
   - Backend: `http://localhost:5000`

---

## Testing

To run the backend unit tests (which verify the CSV utilities, separator detection, and status mapping):
```bash
cd backend
npm run test
```

---

## Sample CSV Dataset for Testing

Copy the following contents and save them as `test_leads.csv` to verify the importer:

```csv
Date Created;Full Name;Mail;Contact Number;Status;Campaign Source;Owner;Description
2026-05-13 14:20:48;John Doe;john.doe@example.com;+91 98765 43210;Good Lead;eden_park;test@gmail.com;Client is asking to reschedule demo
2026/05/13 14:25:30;Sarah Johnson;sarah.johnson@example.com;+91 9876543211;Did Not Connect;sarjapur_plots;test@gmail.com;Person was busy, will try again next week
2026-05-13 14:30:15;Rajesh Patel;rajesh.patel@example.com;+91 98765 43212;Bad Lead;leads_on_demand;test@gmail.com;Not interested in our services
2026-05-13;Priya Singh;priya.singh@example.com;;Sale Done;;test@gmail.com;Deal closed, onboarding in progress
;;;;;;;
Invalid Lead;No Contact Info;test;;;;;
```

---

## Target CRM Fields Reference

The AI maps input columns into the following standard CRM fields:

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `created_at` | String | Lead creation date (normalized to YYYY-MM-DD HH:mm:ss). |
| `name` | String | Contacts's combined full name. |
| `email` | String | Primary email address. |
| `country_code` | String | Phone country dial code (e.g. +91). |
| `mobile_without_country_code` | String | Mobile number (digits only, no country prefix). |
| `company` | String | Company name. |
| `city` | String | Contact city. |
| `state` | String | Contact state. |
| `country` | String | Contact country. |
| `lead_owner` | String | Email or handle of owner. |
| `crm_status` | String | Strictly: `GOOD_LEAD_FOLLOW_UP`, `DID_NOT_CONNECT`, `BAD_LEAD`, or `SALE_DONE`. |
| `crm_note` | String | Remarks, other notes, extra emails/phones. |
| `data_source` | String | Strictly: `leads_on_demand`, `meridian_tower`, `eden_park`, `varah_swamy`, `sarjapur_plots`, or blank. |
| `possession_time` | String | Property possession timeline. |
| `description` | String | Additional description. |
