SMARTAPPLY INDIA: AN AI-POWERED ATS-DRIVEN JOB PORTAL AND RESUME OPTIMIZATION PLATFORM

Ms.S.Priya
Department of Computer Science and Engineering
Nehru Institute of Engineering and Technology
Mail-ID: deepanganeshan05@gmail.com 

M.Gowtham
Department of Computer Science and Engineering
Nehru Institute of Engineering and Technology
Mail-ID: adirm2603@gmail.com

D.Josewin
Department of Computer Science and Engineering
Nehru Institute of Engineering and Technology
Mail-ID: sreeviswanathj@gmail.com 

M.Pandiaraj
Department of Computer Science and Engineering 
Nehru Institute of Engineering and Technology 
Mail ID: shinekp369@gmail.com 

R.Saravanan
Department of Computer Science and Engineering 
Nehru Institute of Engineering and Technology 
Mail-ID: yandipazhani@gmail.com

Abstract- The proposed system presents a smart, scalable, and automated cross-platform mobile application, SmartApply India, designed to assist job seekers through AI-driven resume optimization and an Applicant Tracking System (ATS) evaluation engine. The system integrates advanced AI services and PDF parsing algorithms to continuously evaluate resume compatibility with specific job descriptions. Supabase and Firebase are utilized to securely maintain user profiles, job listings, and authentication records, ensuring robust data management and quick access. Integrated smart algorithms enable automated resume scoring, tailored recommendations, and real-time alerts for job matches. Designed to address the limitations of conventional job portals that lack transparency in the hiring process, the solution enhances a candidate's visibility, prevents unjust ATS rejections, and supports a highly efficient, targeted employment search.

I. INTRODUCTION

The screening of candidates through automated Applicant Tracking Systems (ATS) has posed a significant challenge for job seekers, particularly freshers, due to the inflexible keyword-matching algorithms used by these systems. Existing job portals rely heavily on manual resume submissions without providing candidates actionable feedback on their ATS compatibility, making the process opaque and frustrating. The proposed system, SmartApply India, introduces an intelligent, transparent, and comprehensive job application solution using Flutter, AI technologies, and a custom ATS engine to guide candidates from resume creation to successful job application, ensuring high compatibility and reducing automated rejections.

II. Literature Review

Sharma, R., Gupta, M., and Kumar, P. (2025) proposed a Generative AI-based resume parsing and zero-shot scoring framework for modern recruitment systems to prevent qualified candidates from being filtered out. The authors highlighted that traditional job portals lacking heuristic analysis fail to provide adequate alignment between candidate skills and job descriptions. Their system utilizes Large Language Models (LLMs) to extract context-aware entities at each stage of the resume screening process. The study demonstrated that integrating generative AI ensures deep semantic matching, enhances transparency for job seekers, and improves platform utility by enabling real-time conversational feedback on resume quality.

Chen, Y. and Wang, H. (2025) presented an explainable AI (XAI) transparent recruitment model emphasizing the importance of immediate visibility and real-time ATS scoring in talent acquisition. Their work discussed how opaque filtering processes and simple keyword-matching algorithms contribute to algorithmic bias and high rejection rates for freshers. By adopting an LLM-driven scoring ledger, the proposed approach allows candidates to assess their resumes against job descriptions through natural language reasoning, thereby reducing blind applications, improving success rates, and strengthening user engagement. The study concluded that XAI transparency significantly enhances equity in the hiring ecosystem.

Deshmukh, A. (2025) proposed a mobile-first, edge-computed system for localized job tracking and smart notifications, focusing on secure cross-platform experiences and decoupled serverless architectures. The author explained that using compiled cross-platform frameworks like Flutter, combined with on-device embedding models, ensures seamless UI/UX interactions without heavy reliance on constant cloud inference. The system enables low-latency real-time monitoring of job applications and profile strength, making it particularly suitable for the modern, mobile-centric workforce. The results indicated improved user retention, reduced friction in document uploads, and enhanced overall application resilience.

Roberts, D., Lee, K., and Singh, V. (2025) analyzed discrepancies in resume formatting and explored the potential of Retrieval-Augmented Generation (RAG) to address ATS parsing challenges. Their study emphasized that complex formatting, non-standard fonts, and lack of synchronized terminology between candidates and HR bodies contribute to high false-negative rejection rates. The authors proposed a RAG integration layer as a tool for grounding resume data, improving spatial layout extraction (via tools like Syncfusion PDF and machine vision), and enabling users to automatically inject missing keywords contextually before applying. The research highlighted RAG's role in democratizing access to competitive employment opportunities.

Venkat, S. and Reddy, K. R. (2025) presented a scalable Backend-as-a-Service (BaaS) and Serverless GPU supply-and-demand management system for AI talent acquisition integrated with modern platforms like Supabase. Their work focused on combining real-time database listeners with robust biometric and token-based authentication layers to achieve seamless data transmission and secure record-keeping. The system captured user events and preferences and stored validated information on the cloud while offloading heavy LLM inference to serverless GPU endpoints, enabling automated alerts and job recommendations. The study concluded that transitioning to hybrid BaaaS architectures enhances scalability, reduces backend maintenance, and improves data delivery speeds for AI-heavy job portals.

III. Existing System

In the current employment landscape, the job application process is largely dependent on generic platforms that act merely as a bridge between employers and candidates. Most application processes rely on static resume uploads, lacking any pre-evaluation against the target role. While some digital evaluation tools exist, they are often siloed from the actual job search platforms, lack real-time visibility, and offer generic advice rather than tailored, job-specific modifications. Existing systems also provide limited capability to seamlessly extract text from user PDFs matching modern ATS logic. Furthermore, there is minimal integration of AI-based generative technologies to assist users in phrasing their professional experience, resulting in a high rate of automated rejections. These limitations reduce transparency, hinder effective job matching, and make it difficult for candidates to ensure their applications actually reach human recruiters.

IV. Proposed System

The proposed system, SmartApply India, is an AI-powered, Flutter-based end-to-end recruitment solution designed to monitor, evaluate, and enhance user applications from the point of profile creation to final job submission. Each user profile is equipped with an integrated ATS monitoring tool that continuously matches their uploaded resume (parsed via Syncfusion Flutter PDF) against live job descriptions. The system ensures real-time visibility of ATS compatibility scores and automatically logs all application events on a centralized Supabase backend. An AI Service module is used to provide targeted resume improvements, generate tailored cover letters, and flag missing keywords. By combining automation, secure cloud architecture, and real-time AI feedback, the proposed system enhances application transparency, prevents automated rejections, and strengthens the candidate's position across the job market.

A. Hardware Requirements
Mobile Devices / End-User Devices:
A stable computing device (Smartphone or PC) is required to operate the client application. The mobile device must support the Flutter engine rendering pipeline (Android 5.0+ or iOS 11.0+). Adequate RAM (minimum 2GB) is necessary to ensure smooth PDF parsing and rendering without memory overflow.

Cloud Infrastructure & Servers:
The backend architecture relies on highly available cloud compute instances provided by Supabase and Firebase. This acts as the core processing hub for database queries, user authentication tokens, and API gateways. A stable internet connection is required on the user's hardware to facilitate real-time synchronization with these cloud servers.

B. Software Requirements
Development Framework:
The application is developed using the Flutter SDK (version ^3.11.0) and the Dart programming language. Flutter provides a reactive, component-based UI framework that allows compilation to native code for both iOS and Android from a single codebase.

Backend and Database Platform:
Supabase (an open-source Firebase alternative) and Firebase Core/Auth are used to manage the relational database structure (PostgreSQL), store immutable user credentials, track job bookmarks, and maintain application status. State management is handled internally via the Provider package (^6.1.5+1).

AI and Parsing Modules:
The logic engine incorporates an AI API (such as Gemini or OpenAI) via HTTP protocols for intelligent resume optimization. Local text extraction from resumes is handled by the Syncfusion Flutter PDF library, translating complex document layouts into pure string data for the ATS Engine to evaluate against job descriptions.

V. Conclusion

The proposed end-to-end smart job application system provides an effective solution to overcome ATS barriers and ensure transparency across the hiring pipeline. By integrating an AI-driven evaluation engine with a cross-platform Flutter application, the system enables continuous assessment of candidate resumes against active job listings. Real-time PDF parsing and keyword matching allow candidates to monitor their compatibility, reducing the risk of premature rejection by automated HR software. A major advantage of the system is the use of scalable cloud backends (Supabase/Firebase) for secure user data management. All transactions related to profile updates, bookmarked jobs, and application tracking are stored reliably, ensuring data integrity. The AI service automates resume tailored recommendations, reducing manual guesswork for the user.

The system is highly scalable and adaptable to different employment sectors. The modern UI/UX design offers a seamless mobile experience, while the backend provides a robust foundation for real-time visibility. Overall, the proposed solution offers a smart, transparent, and efficient approach to navigating the modern job market, empowering freshers and experienced candidates alike to achieve legitimate career success.

VII. References

1. Sharma, R., Gupta, M., & Kumar, P. (2025). Generative AI and Zero-Shot Learning for Resume Parsing in Modern Recruitment Systems. ScienceDirect, Elsevier.
2. Chen, Y., & Wang, H. (2025). Explainable AI (XAI) in Hiring: Building a Transparent Recruitment Model Using LLM-Driven ATS Algorithms. Journal of Talent Acquisition, 61(1), 112–129.
3. Deshmukh, A. (2025). Edge-Computed Mobile Systems for Localized Job Tracking and Real-Time Analytics. International Journal of Advanced Computer Science and Applications, 16(2), 85–94.
4. Roberts, D., Lee, K., & Singh, V. (2025). Reconciling Discrepancies in Applicant Tracking Systems: The Potential of Retrieval-Augmented Generation (RAG). Recruitment Technology Review, 30(1), 45–62.
5. Venkat, S., & Reddy, K. R. (2025). Scalable AI Talent Acquisition Using Hybrid Backend-as-a-Service (BaaS) and Serverless GPU Implementation. International Journal of Cloud Applications, 12(1), 34–42.
6. Palanisamy, R. P., Chavez, L. A., Hanson, A. B., Goff, G. S., & Findikoglu, A. T. (2025). Context-Aware Spatial Text Extraction and Layout Analysis in Complex PDF Documents Using Vision Models. ScienceDirect, Elsevier.1
