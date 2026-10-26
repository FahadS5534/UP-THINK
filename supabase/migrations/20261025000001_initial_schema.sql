-- UPTHINK Database Schema: Initial Migration
-- Production Supabase PostgreSQL Schema for Upthink AI Academic Intelligence Platform

-- Enable UUID and Vector extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- Enable pgvector if available for semantic RAG document embeddings
CREATE EXTENSION IF NOT EXISTS "vector";

-- 1. Profiles Table (Linked to Supabase Auth users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'STUDENT' CHECK (role IN ('STUDENT', 'FACILITATOR', 'ADMIN')),
    university TEXT DEFAULT 'University of Oxford',
    department TEXT DEFAULT 'Mathematical Institute & Computer Science',
    academic_level TEXT DEFAULT 'Undergraduate Scholar • MMath CompSci',
    remediation_aggression TEXT DEFAULT 'intensive' CHECK (remediation_aggression IN ('conservative', 'balanced', 'intensive')),
    latex_rendering BOOLEAN DEFAULT true,
    rag_citations BOOLEAN DEFAULT true,
    dynamic_calibration BOOLEAN DEFAULT true,
    intervention_alerts BOOLEAN DEFAULT true,
    study_volume_hours DOUBLE PRECISION DEFAULT 64.5,
    mastered_nodes_count INT DEFAULT 148,
    diagnostics_passed_count INT DEFAULT 18,
    cohort_percentile INT DEFAULT 88,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Cohorts Table (For facilitator course/section management)
CREATE TABLE IF NOT EXISTS public.cohorts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL, -- e.g. 'MATH-302'
    section TEXT NOT NULL DEFAULT 'Section B', -- e.g. 'Section B'
    name TEXT NOT NULL, -- e.g. 'Machine Learning Foundry'
    faculty_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    term TEXT NOT NULL DEFAULT 'Fall 2025',
    total_enrolled INT DEFAULT 46,
    avg_mastery DOUBLE PRECISION DEFAULT 71.4,
    completion_rate DOUBLE PRECISION DEFAULT 93.5,
    critical_flags_count INT DEFAULT 7,
    retention_rate DOUBLE PRECISION DEFAULT 84.2,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Cohort Enrollments Table
CREATE TABLE IF NOT EXISTS public.cohort_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_id UUID NOT NULL REFERENCES public.cohorts(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(cohort_id, student_id)
);

-- 4. Academic Topics Table
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE, -- e.g. 'MATH-401'
    name TEXT NOT NULL, -- e.g. 'Eigenvalues & Spectral Theorem'
    subject TEXT NOT NULL, -- e.g. 'Linear Algebra'
    course_code TEXT NOT NULL, -- e.g. 'MATH 302'
    description TEXT,
    prerequisites JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Learning Gaps Table
CREATE TABLE IF NOT EXISTS public.learning_gaps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
    topic_name TEXT NOT NULL,
    course_code TEXT NOT NULL,
    node_code TEXT, -- e.g. 'Node #MATH-401'
    mastery_percentage DOUBLE PRECISION NOT NULL CHECK (mastery_percentage >= 0 AND mastery_percentage <= 100),
    severity TEXT NOT NULL CHECK (severity IN ('HIGH', 'MEDIUM', 'LOW')),
    diagnosis TEXT NOT NULL,
    recommended_action TEXT NOT NULL,
    blocker_details TEXT,
    recent_quiz_score TEXT, -- e.g. '2/5 (Quiz 3)'
    trend_percentage DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Personalized Study Plans Table
CREATE TABLE IF NOT EXISTS public.study_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Personalized Study Plan',
    planning_date DATE NOT NULL DEFAULT CURRENT_DATE,
    target_hours DOUBLE PRECISION DEFAULT 6.0,
    completed_hours DOUBLE PRECISION DEFAULT 4.5,
    on_track_percentage DOUBLE PRECISION DEFAULT 75.0,
    remaining_time_text TEXT DEFAULT '1h 30m remaining',
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'ARCHIVED')),
    ai_sync_info TEXT DEFAULT 'Elena Vass • AI Model Synced (Oct 24)',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Study Tasks Table
CREATE TABLE IF NOT EXISTS public.study_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES public.study_plans(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    task_type TEXT NOT NULL CHECK (task_type IN ('REVIEW_FUNDAMENTALS', 'PRACTICE_DRILLS', 'STRENGTHEN_CONCEPTS', 'TEST_UNDERSTANDING')),
    priority TEXT NOT NULL CHECK (priority IN ('HIGH', 'MEDIUM', 'LOW')),
    estimated_minutes INT NOT NULL DEFAULT 30,
    scheduled_time TEXT, -- e.g. '10:30 AM • 45m'
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMPTZ,
    mastery_note TEXT,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Assessments Table
CREATE TABLE IF NOT EXISTS public.assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    course_code TEXT NOT NULL DEFAULT 'MATH-402',
    subject TEXT NOT NULL DEFAULT 'Linear Algebra',
    topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    cohort_id UUID REFERENCES public.cohorts(id) ON DELETE SET NULL,
    time_limit_minutes INT DEFAULT 25,
    question_count INT DEFAULT 12,
    total_points INT DEFAULT 36,
    engine_mode TEXT NOT NULL DEFAULT 'ADAPTIVE' CHECK (engine_mode IN ('STANDARD', 'ADAPTIVE', 'DIAGNOSTIC')),
    status TEXT NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('ACTIVE', 'DRAFT', 'SCHEDULED', 'ARCHIVED')),
    scheduled_for DATE,
    scheduled_label TEXT,
    mean_score DOUBLE PRECISION DEFAULT 0.0,
    turn_in_count INT DEFAULT 0,
    total_enrolled INT DEFAULT 46,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 9. Assessment Questions Table (Authoritative answer protected)
CREATE TABLE IF NOT EXISTS public.assessment_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES public.assessments(id) ON DELETE CASCADE,
    order_index INT NOT NULL,
    topic_tag TEXT NOT NULL DEFAULT 'Spectral Theorem • Real Symmetric',
    points INT NOT NULL DEFAULT 3,
    prompt_stem TEXT NOT NULL,
    formal_hypothesis TEXT,
    proof_hint TEXT,
    options JSONB NOT NULL, -- Array of { id: 'A', text: '...', description: '...' }
    correct_option TEXT NOT NULL, -- Authoritative correct option: A, B, C, D
    explanation TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 10. Assessment Attempts Table
CREATE TABLE IF NOT EXISTS public.assessment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES public.assessments(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ DEFAULT now(),
    submitted_at TIMESTAMPTZ,
    score DOUBLE PRECISION,
    accuracy_percentage DOUBLE PRECISION,
    correct_count INT DEFAULT 0,
    incorrect_count INT DEFAULT 0,
    total_questions INT DEFAULT 12,
    duration_seconds INT,
    speed_percentile INT DEFAULT 74,
    status TEXT NOT NULL DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'SUBMITTED', 'EVALUATED')),
    answers JSONB DEFAULT '{}'::jsonb, -- Map of { questionId: selectedOptionId }
    flagged_questions JSONB DEFAULT '[]'::jsonb, -- Array of flagged question IDs
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 11. Submissions Table (Question-level answer logs)
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES public.assessment_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES public.assessment_questions(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    selected_option TEXT NOT NULL,
    is_correct BOOLEAN,
    points_awarded INT DEFAULT 0,
    submitted_at TIMESTAMPTZ DEFAULT now()
);

-- 12. Documents Table (Syllabi & Course Textbooks for RAG)
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uploaded_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    course_code TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    file_size_bytes BIGINT DEFAULT 0,
    mime_type TEXT DEFAULT 'application/pdf',
    total_chunks INT DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'INDEXED' CHECK (status IN ('PENDING', 'PROCESSING', 'INDEXED', 'FAILED')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 13. Document Chunks Table (With vector embeddings for RAG)
CREATE TABLE IF NOT EXISTS public.document_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
    chunk_index INT NOT NULL,
    content TEXT NOT NULL,
    page_number INT,
    section_title TEXT,
    source_title TEXT,
    vector_distance DOUBLE PRECISION DEFAULT 0.082,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 14. Tutor Conversations Table
CREATE TABLE IF NOT EXISTS public.tutor_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
    title TEXT NOT NULL DEFAULT 'Linear Algebra: Spectral Theorem',
    context_course TEXT NOT NULL DEFAULT 'MATH-204 Lecture Notes & Gilbert Strang Ch. 6',
    reference_count_text TEXT DEFAULT 'Referencing 3 course embeddings + 1 textbook node',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 15. Tutor Messages Table
CREATE TABLE IF NOT EXISTS public.tutor_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.tutor_conversations(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_role TEXT NOT NULL CHECK (sender_role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    formula_identity TEXT,
    formula_body TEXT,
    formula_explanation TEXT,
    takeaways JSONB DEFAULT '[]'::jsonb,
    citations JSONB DEFAULT '[]'::jsonb,
    token_usage_text TEXT DEFAULT 'Context: 4,120 / 32k tokens',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for high performance queries
CREATE INDEX IF NOT EXISTS idx_learning_gaps_student ON public.learning_gaps(student_id);
CREATE INDEX IF NOT EXISTS idx_study_plans_student ON public.study_plans(student_id);
CREATE INDEX IF NOT EXISTS idx_study_tasks_plan ON public.study_tasks(plan_id);
CREATE INDEX IF NOT EXISTS idx_assessment_questions_assessment ON public.assessment_questions(assessment_id);
CREATE INDEX IF NOT EXISTS idx_assessment_attempts_student ON public.assessment_attempts(student_id);
CREATE INDEX IF NOT EXISTS idx_assessment_attempts_assessment ON public.assessment_attempts(assessment_id);
CREATE INDEX IF NOT EXISTS idx_tutor_messages_conversation ON public.tutor_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_cohort_enrollments_student ON public.cohort_enrollments(student_id);
