-- UPTHINK Seed Data Migration
-- Prepopulates authentic academic data mirroring the authoritative Stitch design specifications

-- 1. Insert Default Topics
INSERT INTO public.topics (id, code, name, subject, course_code, description)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'MATH-401', 'Eigenvalues & Spectral Theorem', 'Linear Algebra', 'MATH 302', 'Matrix diagonalization, characteristic polynomial proofs, and orthogonal eigenspaces in real symmetric matrices.'),
    ('00000000-0000-0000-0000-000000000002', 'CS-502', 'Stochastic Gradient Descent & Non-Convex Landscapes', 'Machine Learning Foundations', 'CS 881', 'Saddle point instability, Hessian negativity, and stochastic perturbation dynamics in deep architectures.'),
    ('00000000-0000-0000-0000-000000000003', 'STAT-410', 'Bayesian Inference & Conjugate Priors', 'Probability Theory', 'STAT 410', 'Prior and posterior continuous distribution updates and Markov chain Monte Carlo fundamentals.'),
    ('00000000-0000-0000-0000-000000000004', 'MATH-305', 'Vector Spaces & Nullity', 'Linear Algebra', 'MATH 302', 'Rank-nullity theorem, linear independence, dimension theorem, and subspace projections.')
ON CONFLICT (code) DO NOTHING;

-- 2. Insert Default Cohort
INSERT INTO public.cohorts (id, code, section, name, term, total_enrolled, avg_mastery, completion_rate, critical_flags_count, retention_rate)
VALUES 
    ('c0000000-0000-0000-0000-000000000001', 'MATH-302', 'Section B', 'Machine Learning Foundry', 'Fall 2025', 46, 71.4, 93.5, 7, 84.2)
ON CONFLICT DO NOTHING;

-- 3. Insert Default Assessment
INSERT INTO public.assessments (id, title, course_code, subject, time_limit_minutes, question_count, total_points, engine_mode, status, scheduled_label, mean_score, turn_in_count, total_enrolled)
VALUES
    ('a0000000-0000-0000-0000-000000000001', 'Diagnostic #4: Spectral Theorem & Orthogonality', 'MATH-402', 'Linear Algebra', 25, 12, 36, 'ADAPTIVE', 'ACTIVE', 'In 3 Days • Oct 27', 78.4, 43, 46),
    ('a0000000-0000-0000-0000-000000000002', 'Mid-Check: Stochastic Optimization & SGD', 'CS-881', 'Machine Learning', 30, 10, 30, 'ADAPTIVE', 'SCHEDULED', 'Scheduled: Oct 28', 74.0, 0, 88)
ON CONFLICT DO NOTHING;

-- 4. Insert Assessment Questions for Diagnostic #4 (Faithful to Screen 5)
INSERT INTO public.assessment_questions (id, assessment_id, order_index, topic_tag, points, prompt_stem, formal_hypothesis, proof_hint, options, correct_option, explanation)
VALUES
    ('q0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 1, 'Unit 4.1 • Invariant Subspaces', 3, 'Let T be a linear operator on a finite-dimensional vector space V over ℝ. If W is a T-invariant subspace, what condition guarantees the existence of a complementary T-invariant subspace?', 'T(W) ⊆ W', 'Consider orthogonal projection under an inner product where T is self-adjoint.', '[{"id":"A","text":"T must be nilpotent."},{"id":"B","text":"T must be self-adjoint (symmetric) under an inner product on V."},{"id":"C","text":"The dimension of W must equal dim(V)/2."},{"id":"D","text":"W must contain all generalized eigenvectors."}]'::jsonb, 'B', 'By the Spectral Theorem, if T is self-adjoint, the orthogonal complement W^⟂ is automatically T-invariant.'),
    ('q0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 2, 'Gram-Schmidt & Orthogonalization', 3, 'When applying the Gram-Schmidt process to a basis {v_1, ..., v_n}, what does the projection formula ensure for the normalized output vectors {u_1, ..., u_n}?', 'u_k = (v_k - proj(v_k)) / ||...||', 'Inner product evaluates to zero for all pairwise distinct indices.', '[{"id":"A","text":"The vectors span a defective manifold."},{"id":"B","text":"Pairwise inner products satisfy ⟨u_i, u_j⟩ = δ_ij (Kronecker delta)."},{"id":"C","text":"All eigenvalues become strictly imaginary."},{"id":"D","text":"The determinant of the transition matrix is zero."}]'::jsonb, 'B', 'Gram-Schmidt rigorously enforces orthonormality across the spanned sequence.'),
    ('q0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 3, 'Characteristic Polynomial Roots', 3, 'Why does a real symmetric matrix A never exhibit complex eigenvalues with non-zero imaginary parts?', 'A = A^T ∈ ℝ^(n × n)', 'Evaluate v* A v from both perspectives (conjugate transpose).', '[{"id":"A","text":"Because the trace is always zero."},{"id":"B","text":"Because v* A v = λ ||v||^2 and (Av)* v = λ̄ ||v||^2, forcing λ = λ̄."},{"id":"C","text":"Because symmetric matrices cannot be inverted."},{"id":"D","text":"Because algebraic multiplicity is always 1."}]'::jsonb, 'B', 'Taking the conjugate transpose of the Rayleigh quotient proves the eigenvalue must be equal to its complex conjugate, hence real.'),
    ('q0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 4, 'Spectral Theorem • Real Symmetric', 3, 'Consider a real symmetric matrix A ∈ ℝ^(n × n). If λ_1 and λ_2 are two distinct eigenvalues of A with corresponding non-zero eigenvectors v_1 and v_2, which of the following statements rigorously characterizes their eigenspaces?', 'A v_1 = λ_1 v_1 & A v_2 = λ_2 v_2 (λ_1 ≠ λ_2)', '(λ_1 - λ_2)(v_1 · v_2) = 0 ⇒ v_1 ⊥ v_2', '[{"id":"A","text":"The eigenspaces are mutually orthogonal only if det(A) > 0."},{"id":"B","text":"The eigenvectors v_1 and v_2 are strictly orthogonal (v_1 · v_2 = 0) with respect to the standard Euclidean inner product."},{"id":"C","text":"The algebraic multiplicity of each eigenvalue strictly exceeds its geometric multiplicity."},{"id":"D","text":"v_1 and v_2 span a defective subspace of dimension n - 1."}]'::jsonb, 'B', 'By the spectral theorem lemma: (λ_1 - λ_2) ⟨v_1, v_2⟩ = ⟨A v_1, v_2⟩ - ⟨v_1, A v_2⟩ = 0. Since λ_1 ≠ λ_2, we must have ⟨v_1, v_2⟩ = 0.')
ON CONFLICT DO NOTHING;
