AI Powered Book Discovery Platform

Streamlit Demo:

![image alt](https://github.com/DanielJ8/PortfolioProjects/blob/488cf9c2bcfa80d37c972e8d7bb2df883b0f42a2/AI-Powered%20Book%20Discovery%20Platform/streamlit%20ouput.png)

https://ai-powered-book-discovery-platform-bevxtp6teu6wvrlx5g3kns.streamlit.app/

Gradio Demo:

![image alt](https://github.com/DanielJ8/PortfolioProjects/blob/2545be2cff1b4174f36a4e9b03c0626d4b97a503/AI-Powered%20Book%20Discovery%20Platform/Gradio%20output.png)


https://huggingface.co/spaces/Danielj08/AI-Powered-Book-Discovery-Platform

Description: Developed an AI-powered book discovery platform that provides personalized recommendations using semantic similarity and emotion-based filtering. The system leverages dense vector embeddings and transformers for intelligent, context-aware retrieval and user interaction.

Key Responsibilities:

1) Data Preprocessing & Feature Engineering: Performed extensive data cleaning on book metadata (CSV), handling missing values through imputation and strategic removal. Engineered new features such as "age of book" and "missing description indicator" to enhance data utility.

2) Vector Database Implementation: Utilized HuggingFaceEmbeddings,Chroma and Faiss(for streamlit deployment) to convert book descriptions into dense semantic vectors, enabling efficient similarity search for recommendations. Managed the persistence of the vector store for efficient retrieval.

3) Zero-Shot Text Classification: Implemented a transformers pipeline (facebook/bart-large-mnli) for zero-shot classification to categorize books into broader "Fiction" and "Nonfiction" categories, and to impute missing category labels.

4) Emotion Detection: Integrated a pre-trained RoBERTa model (j-hartmann/emotion-english-distilroberta-base) to extract emotional tones (joy, sadness, fear, anger, surprise, neutral) from book descriptions, allowing for emotionally nuanced recommendations.

5) Interactive Web Application (Gradio): Built a user-friendly web interface using Gradio and streamlit for users to input queries, filter by category, and select desired emotional tones, showcasing the recommendation system's capabilities.

Tools & Technologies: Python, Pandas, Matplotlib, Seaborn, NumPy, transformers (HuggingFace), LangChain, ChromaDB, FAISS, Streamlit Gradio, scikit-learn .
