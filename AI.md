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

Kesimpulan :
Sekarang untuk membuat agent ai yang seperti trae
belum ada yang sekali bundle dlm file .exe 
harus rakit satu-satu setiap package yang dibutuhkan