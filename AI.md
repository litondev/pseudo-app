Difinition : 
AI → Aplikasi komputer yang membantu manusia untuk analisis, prediksi, otomatisasi, dsb.
  Hybrid → Gabungan beberapa metode AI
  Rule-Based / Symbolic → AI berbasis aturan/logika manual
  Search & Optimization → AI untuk mencari solusi terbaik (pathfinding, optimisasi)
  Logic & Reasoning → AI berbasis logika formal (Prolog, inferensi)
  Probabilistic / Statistical AI → AI pakai probabilitas/statistik (Bayesian Network, HMM)
  Evolutionary / Bio-inspired → AI terinspirasi alam (Genetic Algorithm, Swarm Intelligence)
  ML → Metode agar komputer belajar dari data
       (90% AI modern menggunakan ML)
       - Bisa punya metode selain DL: Random Forest, SVM, KNN
       Supervised Learning → Belajar dari data berlabel
       Unsupervised Learning → Belajar dari data tanpa label
       Reinforcement Learning → Belajar dari trial & error       
       DL → Subset ML yang lebih kompleks, menggunakan jaringan saraf
           NLP → Analisis teks/bahasa/kalimat
               LLM → Model NLP sangat besar & kompleks (ChatGPT, Meta AI)
           CV → Computer Vision, analisis gambar/video
           RL → Reinforcement Learning untuk robot/agen


Python Package Custom Ai Agent : 

PyTorch / TensorFlow
framework deep learning yang memungkinkan pembuatan dan pelatihan model neural network secara fleksibel dan efisien.

Transformers 
library dari Hugging Face yang menyediakan implementasi berbagai model state-of-the-art untuk tugas-tugas NLP, visi, audio, dan multimodal.

LangChain
framework untuk membangun aplikasi berbasis LLM yang dapat menggabungkan berbagai komponen dan integrasi pihak ketiga untuk menyederhanakan pengembangan aplikasi AI.

LlamaIndex 
menyediakan alat untuk membangun sistem AI yang dapat mengakses dan memproses data dari berbagai sumber, memungkinkan pembuatan agen AI yang dapat menjawab pertanyaan berdasarkan data tersebut.

OpenAI API 
Layanan online dari OpenAI untuk mengakses LLM (seperti GPT) tanpa harus download model besar.

AutoGPT
Framework untuk membuat AI agent autonomous / multi-step.

Watchdog
Library Python untuk monitor folder / file.

FAISS
Library untuk vector similarity search dari Facebook AI.

SentenceTransformers
Library untuk mengubah teks menjadi vector (embedding).

Gradio / Streamlit 
Library untuk buat UI interaktif lokal atau web.

Ollama
Framework ringan untuk menjalankan model bahasa (LLM) secara lokal di komputer Anda.

Continue 
Platform untuk membangun dan menjalankan agen AI kustom di IDE (seperti VS Code atau JetBrains), terminal, dan CI/CD pipeline.

DeepSeek Coder
Seri model bahasa yang dilatih khusus untuk kode, dengan ukuran mulai dari 1B hingga 33B parameter.

StarCode
Model bahasa yang dilatih pada lebih dari 80 bahasa pemrograman dan teks natural dari GitHub, termasuk issues dan commits.

CodeLlama
Seri model bahasa untuk kode berdasarkan Llama 2, dengan varian seperti CodeLlama, CodeLlama-Python, dan CodeLlama-Instruct.

Diagaram : 
┌───────────────────────────┐
│       USER INTERFACE      │
│                           │
│  Gradio / Streamlit       │
│  Rich (terminal output)   │
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│      AGENT ORCHESTRATION  │
│                           │
│  LangChain                │
│  AutoGPT / Continue       │
│  LlamaIndex               │
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│     LANGUAGE / CODE MODEL │
│                           │
│  Transformers             │
│  CodeLlama / DeepSeek     │
│  StarCode                 │
│  Ollama (local LLM)       │
│  OpenAI API (optional)    │
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│      EMBEDDING & SEARCH   │
│                           │
│  SentenceTransformers     │
│  FAISS                    │
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│   FILE & FOLDER MANAGEMENT│
│                           │
│  Watchdog                 │
│  os / shutil / pathlib     │
│  subprocess (exec code)   │
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│   UTILITY & SYSTEM LAYER  │
│                           │
│  logging / rich           │
│  psutil (resource monitor)│
│  asyncio / schedule       │
│  docker / docker-py       │
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│      DEEP LEARNING CORE   │
│                           │
│  PyTorch / TensorFlow     │
│  Transformers backend     │
└───────────────────────────┘


AI Automation & Orchestration Tools
BELAJAR*****
- n8n -> MENGABUNGKAN AI DENGAN APLIKASI LAIN
 Low-code automation platform** (mirip Zapier tapi open-source).
 Bisa integrasi API, AI model, database, dll untuk membuat alur kerja otomatis.
 Contoh: ambil data dari Notion → kirim ke OpenAI → hasilnya di-post ke Slack.

- RAG (Retrieval-Augmented Generation) -> GABUNGAN UTK LLM
 Teknik untuk memberi “otak tambahan” ke LLM.
 Model tidak hanya mengandalkan ingatan internal tapi juga “mengambil” data relevan dari database/vector store (mis. FAISS, Pinecone) sebelum menjawab.
 Digunakan pada chatbot seperti ChatGPT + knowledge base perusahaan.

- FastGPT LAWANYA CHATGPT
 Platform open-source mirip ChatGPT dengan fitur RAG, integrasi data sendiri, dan manajemen percakapan.
 Bisa dijalankan lokal atau di server sendiri.
 Cocok buat bikin chatbot cerdas berbasis dokumen internal.

- CrewAI -> LAWANYA n8n
 Framework untuk **membuat multi-agent AI system** (beberapa AI bekerja sama untuk tugas kompleks).
 Misal: 1 agent riset → 1 agent menulis → 1 agent validasi hasil.
 Cocok untuk AI yang bekerja kolaboratif seperti tim manusia.


 CLI / App Builder / Frontend for AI
- gemini-cli -> SDK GEMINI AI  
 CLI (Command Line Interface) untuk menggunakan **Google Gemini model** langsung dari terminal.
 Cocok buat developer yang ingin akses cepat model Gemini tanpa UI web.

- Dify -> LAWANNYA n8n
 Platform no/low-code untuk **buat AI app + RAG + workflow**.
 Gabungan antara LangChain, FastGPT, dan n8n.
 Bisa drag-drop AI node, query ke database, dan uji prompt.
 Sangat populer untuk bikin produk berbasis AI dengan cepat.

- LangFlow -> LAWANNYA n8n
 UI visual (flow builder) untuk **LangChain**.
 Bisa drag-drop node (LLM, retriever, memory, output) tanpa coding berat.
 Ideal untuk eksplorasi pipeline LLM.

- Streamlit -> APLIKASI WEB
 Framework Python untuk bikin **web app cepat dan interaktif**.
 Banyak dipakai untuk prototipe AI (misal upload dokumen → chat dengan AI).

- Gradio -> APLIKASI WEB
 Mirip Streamlit tapi fokus pada **demo model ML/AI**.
 Banyak dipakai oleh HuggingFace untuk menampilkan demo model.


Core Frameworks / Libraries for LLM & AI
- LangGraph  -> TERHUBUNG DENGAN RAG -> DIATAS RAQ
 Framework baru dari LangChain untuk **membangun agent dengan kontrol penuh atas alur (graph-based)**.
 Bisa buat agent multi-step, branching logic, atau memory jangka panjang.

- sentence-transformers -> TERHUBUNG DENGAN RAG -> DIATASNYA FAISS
 Library untuk **membuat dan menggunakan embedding teks** (misal: SBERT).
 Dipakai dalam RAG untuk mencari kesamaan makna antar kalimat.

- AutoGPT -> LAWANNYA n8n
 Eksperimen awal “autonomous AI agent” — AI yang bisa membuat rencana dan eksekusi sendiri.
 Sekarang konsepnya diambil alih oleh framework seperti CrewAI, LangGraph, dll.

- openai-python -> SDK OPEN AI
 SDK resmi untuk akses model OpenAI (GPT-4, Whisper, DALL·E, dll) lewat Python.
 Dasar integrasi API di aplikasi AI modern.

- faiss -> TERHUBUNG DENGAN RAG -> DIBAWAH RAG
 **Vector database** dari Facebook untuk pencarian kesamaan cepat (vector search).
 Dipakai dalam RAG untuk menemukan teks paling relevan dengan query user.


Machine Learning Core Frameworks
- TensorFlow
 Framework ML dari Google (stabil, banyak digunakan untuk model klasik dan deep learning).
 Kurang populer untuk LLM modern, tapi masih kuat untuk training custom NN.

- PyTorch
 Framework ML dari Meta, **lebih populer** untuk riset dan model modern (termasuk LLM).
 Digunakan oleh HuggingFace, OpenAI, Stability AI, dll.


LLM Tools / Frameworks
- LlamaIndex (dulu GPT Index) -> TRAINER MENGATUR TINDAKAN KE MODEL TERHUBUNG DENGAN RAG  
 Framework untuk **membangun RAG pipeline dengan data eksternal** (PDF, DB, API).
 Integrasi mudah dengan LangChain, FastGPT, atau Dify.

- LangChain -> TRAINER DATA-DATA FILE KE MODEL TERHUBUNG DENGAN RAG
 Framework paling populer untuk **membangun aplikasi berbasis LLM modular** (RAG, agent, tool calling, memory).
 Jadi fondasi banyak platform seperti FastGPT, Dify, LangFlow.

- Transformers -> TRAINER MODEL LLM
 Library utama dari HuggingFace untuk **memanggil dan melatih model LLM** (GPT, BERT, T5, dll).
 Inti dari semua aplikasi NLP/LLM modern.


LLM Coding Models
BELAJAR *****
- Continue ->  VS CODE EXTENSION UNTUK CODING DENGAN LLM SENDIRI
 Open-source **VSCode AI assistant** yang bisa pakai model lokal (Ollama, Llama) atau API (GPT).
 Mirip GitHub Copilot tapi bebas dan bisa diatur sendiri.

BELAJAR *****
- Ollama -> LLM FREE OPEN SOURCE UMUM
 Platform untuk menjalankan **LLM secara lokal (offline)** di PC/Mac.
 Bisa jalankan model seperti Llama, Mistral, Gemma, DeepSeek tanpa koneksi internet.
 Sangat cocok untuk developer yang ingin privasi penuh dan tanpa biaya API.

- DeepSeek-Coder -> LLM FREE OPEN SOURCE KHUSUS CODING
 Open-source **coding model LLM** (mirip CodeLlama, Codex).
 Fokus untuk membantu menulis, debug, dan memahami kode.

- StarCoder -> LLM FREE OPEN SOURCE KHUSUS CODING
 Model code generation dari **HuggingFace + ServiceNow**.
 Salah satu model open-source terbaik untuk pemrograman multi-bahasa.

- CodeLlama -> LLM FREE OPEN SOURCE KHUSUS CODING
 Model AI buatan Meta khusus untuk **pemrograman dan refactor code**.
 Sering digunakan sebagai alternatif Codex/OpenAI jika ingin open-source.

BUAT AI AGENT SENDIRI :
- VS Code
- CodeGPT extension
- Ollama (pakai model seperti deepseek-coder atau llama3:70b)
- Dan kalau nanti mau naik level (biar bisa multi-step planning seperti Trae yang “berpikir sendiri”),
tinggal tambah:
Continue (untuk planning agent) atau LangGraph / CrewAI (kalau mau sistem AI lebih canggih)

Kesimpulan :
Sekarang untuk membuat agent ai yang seperti trae
belum ada yang sekali bundle dlm file .exe 
harus rakit satu-satu setiap package yang dibutuhkan
