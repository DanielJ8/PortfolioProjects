AI Powered Book Discovery Platform

Description: Developed an ai powered book discovery platform leveraging RAG to provide personalized book suggestions.

Key Responsibilities:

Data Preprocessing & Feature Engineering: Performed extensive data cleaning on book metadata (CSV), handling missing values through imputation and strategic removal. Engineered new features such as "age of book" and "missing description indicator" to enhance data utility.

Vector Database Implementation: Utilized HuggingFaceEmbeddings,Chroma and Faiss(for streamlit deployment) to convert book descriptions into dense semantic vectors, enabling efficient similarity search for recommendations. Managed the persistence of the vector store for efficient retrieval.

Zero-Shot Text Classification: Implemented a transformers pipeline (facebook/bart-large-mnli) for zero-shot classification to categorize books into broader "Fiction" and "Nonfiction" categories, and to impute missing category labels.

Emotion Detection: Integrated a pre-trained RoBERTa model (j-hartmann/emotion-english-distilroberta-base) to extract emotional tones (joy, sadness, fear, anger, surprise, neutral) from book descriptions, allowing for emotionally nuanced recommendations.

Interactive Web Application (Gradio): Built a user-friendly web interface using Gradio and streamlit for users to input queries, filter by category, and select desired emotional tones, showcasing the recommendation system's capabilities.

Tools & Technologies: Python, Pandas, Matplotlib, Seaborn, NumPy, transformers (HuggingFace), LangChain, ChromaDB, FAISS, Streamlit Gradio, scikit-learn .
