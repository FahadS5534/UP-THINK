-- UPTHINK Row Level Security (RLS) Policies Migration
-- Secures multi-tenant student & facilitator access and prevents unauthorized elevation or tampering

-- Enable RLS across all application tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cohorts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cohort_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_gaps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.document_chunks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_messages ENABLE ROW LEVEL SECURITY;

-- Helper function to check if requesting user is a facilitator
CREATE OR REPLACE FUNCTION public.is_facilitator(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = user_id AND (role = 'FACILITATOR' OR role = 'ADMIN')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 1. Profiles Policies
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id OR public.is_facilitator(auth.uid()));

CREATE POLICY "Users can update own profile preferences"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (
        auth.uid() = id
        -- Prevent role elevation by normal users:
        AND (role = (SELECT role FROM public.profiles WHERE id = auth.uid()))
    );

CREATE POLICY "Public registration inserts profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- 2. Cohorts Policies
CREATE POLICY "Facilitators can manage their cohorts"
    ON public.cohorts FOR ALL
    USING (faculty_id = auth.uid() OR public.is_facilitator(auth.uid()));

CREATE POLICY "Students can view enrolled cohorts"
    ON public.cohorts FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.cohort_enrollments
            WHERE cohort_id = public.cohorts.id AND student_id = auth.uid()
        )
    );

-- 3. Cohort Enrollments Policies
CREATE POLICY "Facilitators can view and manage enrollments"
    ON public.cohort_enrollments FOR ALL
    USING (public.is_facilitator(auth.uid()));

CREATE POLICY "Students can view their own enrollments"
    ON public.cohort_enrollments FOR SELECT
    USING (student_id = auth.uid());

-- 4. Topics Policies
CREATE POLICY "Topics are readable by authenticated users"
    ON public.topics FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Facilitators can manage topics"
    ON public.topics FOR ALL
    USING (public.is_facilitator(auth.uid()));

-- 5. Learning Gaps Policies
CREATE POLICY "Students can view their own learning gaps"
    ON public.learning_gaps FOR SELECT
    USING (student_id = auth.uid() OR public.is_facilitator(auth.uid()));

CREATE POLICY "System and students can modify learning gaps"
    ON public.learning_gaps FOR ALL
    USING (student_id = auth.uid() OR public.is_facilitator(auth.uid()));

-- 6. Study Plans & Tasks Policies
CREATE POLICY "Students can manage their study plans"
    ON public.study_plans FOR ALL
    USING (student_id = auth.uid() OR public.is_facilitator(auth.uid()));

CREATE POLICY "Students can manage their study tasks"
    ON public.study_tasks FOR ALL
    USING (student_id = auth.uid() OR public.is_facilitator(auth.uid()));

-- 7. Assessments Policies
CREATE POLICY "Students can view published or active assessments"
    ON public.assessments FOR SELECT
    TO authenticated
    USING (status IN ('ACTIVE', 'SCHEDULED') OR public.is_facilitator(auth.uid()));

CREATE POLICY "Facilitators can manage all assessments"
    ON public.assessments FOR ALL
    USING (public.is_facilitator(auth.uid()));

-- 8. Assessment Questions Policies
-- Strict: Students can view question stems & options, but correct_option and grading key are verified server-side
CREATE POLICY "Questions readable for active assessments"
    ON public.assessment_questions FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.assessments
            WHERE id = assessment_id AND (status IN ('ACTIVE', 'SCHEDULED') OR public.is_facilitator(auth.uid()))
        )
    );

CREATE POLICY "Facilitators manage questions"
    ON public.assessment_questions FOR ALL
    USING (public.is_facilitator(auth.uid()));

-- 9. Assessment Attempts & Submissions Policies
CREATE POLICY "Students can view and create their own attempts"
    ON public.assessment_attempts FOR ALL
    USING (student_id = auth.uid() OR public.is_facilitator(auth.uid()));

CREATE POLICY "Students can log their answers"
    ON public.submissions FOR ALL
    USING (student_id = auth.uid() OR public.is_facilitator(auth.uid()));

-- 10. Documents & Chunks Policies (Syllabus RAG security)
CREATE POLICY "Users can access syllabus documents"
    ON public.documents FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Facilitators can upload documents"
    ON public.documents FOR ALL
    USING (uploaded_by = auth.uid() OR public.is_facilitator(auth.uid()));

CREATE POLICY "Document chunks are readable by authenticated users"
    ON public.document_chunks FOR SELECT
    TO authenticated
    USING (true);

-- 11. Tutor Conversations & Messages Policies
CREATE POLICY "Students own their tutor conversations"
    ON public.tutor_conversations FOR ALL
    USING (student_id = auth.uid());

CREATE POLICY "Students own their tutor messages"
    ON public.tutor_messages FOR ALL
    USING (student_id = auth.uid());
