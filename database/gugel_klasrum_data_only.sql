-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.4.3 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang data untuk tabel gugel_klasrum.assignments: ~2 rows (lebih kurang)
INSERT INTO `assignments` (`id`, `course_id`, `type`, `topic_id`, `title`, `description`, `points`, `deadline`, `assign_all`, `created_at`, `updated_at`, `question_type`, `choices`) VALUES
	(1, 1, 'assignment', NULL, 'Tugas Audit Program dan Audit Plan', 'Kumpulkan audit plan kelompok. Cukup ketua kelompok yang mengumpulkan.', 100, '2026-10-30 23:59:00', 1, '2026-10-16 17:40:54', '2026-10-16 17:40:54', NULL, NULL),
	(2, 11, 'assignment', NULL, 'pemrograman aplikasi tugas 1', 'kumpulkan tugas 1', 100, NULL, 1, '2026-10-18 13:34:17', '2026-10-18 13:34:17', NULL, NULL);

-- Membuang data untuk tabel gugel_klasrum.assignment_attachments: ~1 rows (lebih kurang)
INSERT INTO `assignment_attachments` (`id`, `assignment_id`, `type`, `name`, `url`, `created_at`, `updated_at`) VALUES
	(1, 2, 'file', 'Naskah Soal UTS Pemrograman Aplikasi Bergerak 2026.pdf', NULL, '2026-10-18 13:34:17', '2026-10-18 13:34:17');

-- Membuang data untuk tabel gugel_klasrum.assignment_recipients: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.cache: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.cache_locks: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.comments: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.courses: ~11 rows (lebih kurang)
INSERT INTO `courses` (`id`, `name`, `description`, `section`, `room`, `subject`, `level`, `code`, `teacher_id`, `invite_enabled`, `post_policy`, `notify_mode`, `created_at`, `updated_at`) VALUES
	(1, 'Audit Sistem Informasi', NULL, NULL, NULL, NULL, NULL, 'audit001', 6, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(2, 'Literasi Digital187', NULL, 'Rabu, 07.00 - Selesai', NULL, NULL, NULL, 'literas2', 7, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(3, 'KSI-G', NULL, NULL, NULL, NULL, NULL, 'ksig0003', 8, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(4, 'Manajemen Layanan Pelanggan', NULL, 'S1 SI MLP03 RABU Jam 07:00 - 12:00 A10.', NULL, NULL, NULL, 'mlp03rab', 9, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(5, 'Keamanan sistem informasi', NULL, '2024', NULL, NULL, NULL, 'keamanan', 10, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(6, '2024 G - Analisis dan Perancangan Sistem', NULL, NULL, NULL, NULL, NULL, 'apsi2024', 10, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(7, 'SBD 2024G', NULL, NULL, NULL, NULL, NULL, 'sbd2024g', 10, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(8, 'g', NULL, NULL, NULL, NULL, NULL, '76bkzssv', 1, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:46:59', '2026-10-16 17:46:59'),
	(9, 'celos', NULL, NULL, NULL, NULL, NULL, 'gv0iuhye', 1, 1, 'students_post_and_comment', 'condensed', '2026-10-16 17:47:49', '2026-10-16 17:47:49'),
	(10, 'mk audit', NULL, NULL, NULL, NULL, NULL, '0kjfqim3', 6, 1, 'students_post_and_comment', 'condensed', '2026-10-18 04:46:13', '2026-10-18 04:46:13'),
	(11, 'h', NULL, NULL, NULL, NULL, NULL, '6zcciwn4', 18, 1, 'students_post_and_comment', 'condensed', '2026-10-18 13:32:33', '2026-10-18 13:32:33');

-- Membuang data untuk tabel gugel_klasrum.course_user: ~55 rows (lebih kurang)
INSERT INTO `course_user` (`id`, `course_id`, `user_id`, `role`, `created_at`, `updated_at`) VALUES
	(1, 1, 6, 'teacher', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(2, 1, 1, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(3, 1, 2, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(4, 1, 3, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(5, 1, 4, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(6, 1, 5, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(7, 2, 7, 'teacher', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(8, 2, 1, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(9, 2, 2, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(10, 2, 3, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(11, 2, 4, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(12, 2, 5, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(13, 3, 8, 'teacher', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(14, 3, 1, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(15, 3, 2, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(16, 3, 3, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(17, 3, 4, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(18, 3, 5, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(19, 4, 9, 'teacher', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(20, 4, 1, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(21, 4, 2, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(22, 4, 3, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(23, 4, 4, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(24, 4, 5, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(25, 5, 10, 'teacher', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(26, 5, 1, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(27, 5, 2, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(28, 5, 3, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(29, 5, 4, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(30, 5, 5, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(31, 6, 10, 'teacher', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(32, 6, 1, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(33, 6, 2, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(34, 6, 3, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(35, 6, 4, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(36, 6, 5, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(37, 7, 10, 'teacher', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(38, 7, 1, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(39, 7, 2, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(40, 7, 3, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(41, 7, 4, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(42, 7, 5, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(43, 1, 11, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(44, 1, 12, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(45, 1, 13, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(46, 1, 14, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(47, 1, 15, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(48, 1, 16, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(49, 1, 17, 'student', '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(50, 8, 1, 'teacher', '2026-10-16 17:46:59', '2026-10-16 17:46:59'),
	(51, 9, 1, 'teacher', '2026-10-16 17:47:49', '2026-10-16 17:47:49'),
	(52, 10, 6, 'teacher', '2026-10-18 04:46:13', '2026-10-18 04:46:13'),
	(53, 10, 1, 'student', '2026-10-18 04:47:42', '2026-10-18 04:47:42'),
	(54, 11, 18, 'teacher', '2026-10-18 13:32:33', '2026-10-18 13:32:33'),
	(55, 11, 1, 'student', '2026-10-18 13:35:32', '2026-10-18 13:35:32');

-- Membuang data untuk tabel gugel_klasrum.failed_jobs: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.feedback: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.jobs: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.job_batches: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.notifications: ~10 rows (lebih kurang)
INSERT INTO `notifications` (`id`, `user_id`, `course_id`, `title`, `body`, `read_at`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, 'Tugas baru: Tugas Audit Program dan Audit Plan', 'Audit Sistem Informasi', NULL, '2026-10-15 04:31:00', '2026-10-15 04:31:00'),
	(2, 1, 1, 'Rahadian Bisma memposting pengumuman baru', 'Audit Sistem Informasi', NULL, '2026-10-15 01:54:00', '2026-10-15 01:54:00'),
	(3, 2, 1, 'Tugas baru: Tugas Audit Program dan Audit Plan', 'Audit Sistem Informasi', NULL, '2026-10-15 04:31:00', '2026-10-15 04:31:00'),
	(4, 2, 1, 'Rahadian Bisma memposting pengumuman baru', 'Audit Sistem Informasi', NULL, '2026-10-15 01:54:00', '2026-10-15 01:54:00'),
	(5, 3, 1, 'Tugas baru: Tugas Audit Program dan Audit Plan', 'Audit Sistem Informasi', NULL, '2026-10-15 04:31:00', '2026-10-15 04:31:00'),
	(6, 3, 1, 'Rahadian Bisma memposting pengumuman baru', 'Audit Sistem Informasi', NULL, '2026-10-15 01:54:00', '2026-10-15 01:54:00'),
	(7, 4, 1, 'Tugas baru: Tugas Audit Program dan Audit Plan', 'Audit Sistem Informasi', NULL, '2026-10-15 04:31:00', '2026-10-15 04:31:00'),
	(8, 4, 1, 'Rahadian Bisma memposting pengumuman baru', 'Audit Sistem Informasi', NULL, '2026-10-15 01:54:00', '2026-10-15 01:54:00'),
	(9, 5, 1, 'Tugas baru: Tugas Audit Program dan Audit Plan', 'Audit Sistem Informasi', NULL, '2026-10-15 04:31:00', '2026-10-15 04:31:00'),
	(10, 5, 1, 'Rahadian Bisma memposting pengumuman baru', 'Audit Sistem Informasi', NULL, '2026-10-15 01:54:00', '2026-10-15 01:54:00');

-- Membuang data untuk tabel gugel_klasrum.password_reset_tokens: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.personal_access_tokens: ~12 rows (lebih kurang)
INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
	(1, 'App\\Models\\User', 1, 'mobile', 'ecfca0e8c7f73456b49cd95145ad12f42d5fbcd0d5a2f9469df9f675288f805d', '["*"]', '2026-10-18 04:52:21', NULL, '2026-10-16 17:43:25', '2026-10-18 04:52:21'),
	(2, 'App\\Models\\User', 6, 'mobile', 'fc93ed969a7cf84e47c633b7f357c4798dc26745bc9728cc27384480a290522a', '["*"]', '2026-10-18 04:49:50', NULL, '2026-10-16 17:49:25', '2026-10-18 04:49:50'),
	(3, 'App\\Models\\User', 1, 'mobile', '86cca138941d40878adf28f242b43b94a96366c56186ee2fc86bded63d4e4325', '["*"]', '2026-10-18 10:15:38', NULL, '2026-10-18 10:15:12', '2026-10-18 10:15:38'),
	(4, 'App\\Models\\User', 1, 'mobile', '38714506bf2b4685f8d267046c09f73eec3deb29ee2684666285b209d2b09cfe', '["*"]', '2026-10-18 10:24:02', NULL, '2026-10-18 10:23:33', '2026-10-18 10:24:02'),
	(5, 'App\\Models\\User', 1, 'mobile', '76eeba48544f4f6d5284dd4f5b77fb71d8b7dcc571e212c156fc702b24c3caf7', '["*"]', '2026-10-18 10:38:25', NULL, '2026-10-18 10:37:55', '2026-10-18 10:38:25'),
	(6, 'App\\Models\\User', 18, 'mobile', 'e4cb15a028c8a2d552283f0105db639b91a4cce9f253e691a430fa8f04ece6bf', '["*"]', '2026-10-18 13:28:23', NULL, '2026-10-18 13:28:22', '2026-10-18 13:28:23'),
	(7, 'App\\Models\\User', 1, 'mobile', 'ff935f7fc7a38521ad68714b603aeef84414fc164ea61571c266acfc0abc5ffd', '["*"]', '2026-10-18 13:37:47', NULL, '2026-10-18 13:31:16', '2026-10-18 13:37:47'),
	(8, 'App\\Models\\User', 18, 'mobile', 'aee13216bcdb3bef5f5390a266fbaf389e73bb3d5c6d36a2cdebff8b564e5fe3', '["*"]', '2026-10-18 13:36:43', NULL, '2026-10-18 13:32:13', '2026-10-18 13:36:43'),
	(9, 'App\\Models\\User', 19, 'mobile', '9e401f020c5928414844adbee31a298705725ca7b89681760f9cf0eae9ec81b3', '["*"]', '2026-10-18 17:31:05', NULL, '2026-10-18 17:31:04', '2026-10-18 17:31:05'),
	(10, 'App\\Models\\User', 1, 'mobile', 'e79979fda098ed6d00559a46830d489a36e16679f9079fe7c9e4fd87686256f9', '["*"]', '2026-10-18 17:33:44', NULL, '2026-10-18 17:33:15', '2026-10-18 17:33:44'),
	(11, 'App\\Models\\User', 20, 'mobile', '601f3a2ab36bffb55e90b3f107c856eccee9bbe4f12d3d7e20955a59abc15baa', '["*"]', '2026-10-19 03:34:20', NULL, '2026-10-19 03:34:20', '2026-10-19 03:34:20'),
	(12, 'App\\Models\\User', 1, 'mobile', 'c4f6ffff284dea2d6f9fb037d8e5ab4e731008b7ed67c6cfddf40808557378ff', '["*"]', '2026-10-19 03:36:39', NULL, '2026-10-19 03:36:10', '2026-10-19 03:36:39');

-- Membuang data untuk tabel gugel_klasrum.posts: ~5 rows (lebih kurang)
INSERT INTO `posts` (`id`, `course_id`, `user_id`, `content`, `is_assignment`, `created_at`, `updated_at`) VALUES
	(1, 1, 6, 'Tugas Audit Program dan Audit Plan', 1, '2026-10-15 04:31:00', '2026-10-15 04:31:00'),
	(2, 1, 6, 'Tugas Audit plan. silahkan dikumpulkan disini.\ncukup ketua kelompok yang mengumpulkan,\nTuliskan\n\n• Objek Audit/Standart\n• nama anggota,\n• nim,\n• kelas', 0, '2026-10-15 01:54:00', '2026-10-15 01:54:00'),
	(3, 10, 1, 'kumpulkan laporan yang sudah saya berikan', 0, '2026-10-18 04:49:22', '2026-10-18 04:49:22'),
	(4, 9, 1, 'tugas', 0, '2026-10-18 04:52:21', '2026-10-18 04:52:21'),
	(5, 11, 18, 'pemrograman aplikasi tugas 1', 1, '2026-10-18 13:34:17', '2026-10-18 13:34:17');

-- Membuang data untuk tabel gugel_klasrum.quiz_questions: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.sessions: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.submissions: ~1 rows (lebih kurang)
INSERT INTO `submissions` (`id`, `assignment_id`, `user_id`, `status`, `submitted_at`, `created_at`, `updated_at`, `answer`, `answers`, `score`) VALUES
	(1, 2, 1, 'done', '2026-10-18 13:35:56', '2026-10-18 13:35:56', '2026-10-18 13:36:40', NULL, NULL, 100);

-- Membuang data untuk tabel gugel_klasrum.submission_attachments: ~1 rows (lebih kurang)
INSERT INTO `submission_attachments` (`id`, `submission_id`, `type`, `name`, `url`, `created_at`, `updated_at`) VALUES
	(1, 1, 'file', 'WhatsApp Image 2026-10-18 at 16.49.30.jpeg', NULL, '2026-10-18 13:35:56', '2026-10-18 13:35:56');

-- Membuang data untuk tabel gugel_klasrum.topics: ~0 rows (lebih kurang)

-- Membuang data untuk tabel gugel_klasrum.users: ~20 rows (lebih kurang)
INSERT INTO `users` (`id`, `name`, `email`, `photo_url`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
	(1, '228_ Alif Muhammad Hafizh', '24051214228@mhs.unesa.ac.id', NULL, NULL, '$2y$12$26ZWB9rmXrG6NcIsvjIg4et0eX/PFt4PS9Q2EOGgf.YzacFmm2Op2', NULL, '2026-10-16 17:40:48', '2026-10-16 17:40:48'),
	(2, 'Alf Game', 'alfgame321@gmail.com', NULL, NULL, '$2y$12$p3OrIVmAFBS/qNs1rLAd9u5HLqmNik8PrrKx0ansgae9ONdcDxVvW', NULL, '2026-10-16 17:40:48', '2026-10-16 17:40:48'),
	(3, 'Alif Muhammad', 'alifscc0311@gmail.com', NULL, NULL, '$2y$12$jHhLNYCpwT.N3RIeAHwxVuV69bqPkoYGSKigI5NzFaXffOkumqg4e', NULL, '2026-10-16 17:40:49', '2026-10-16 17:40:49'),
	(4, 'soto cak ipin', 'sotoayamcakipinktt@gmail.com', NULL, NULL, '$2y$12$mjz4xjFSBW3v8VSmqVo7je2TvFEWjgRDK.vmfWpOd3DdLSWEyvI.6', NULL, '2026-10-16 17:40:49', '2026-10-16 17:40:49'),
	(5, 'Alif Hafizh', 'alifmhafizh0311@gmail.com', NULL, NULL, '$2y$12$SUROho1TTquysuBexgAWSeHJDU4S0tjrPOrqkXHxJDY2uIOxYrLQu', NULL, '2026-10-16 17:40:49', '2026-10-16 17:40:49'),
	(6, 'Rahadian Bisma', 'rahadian.bisma@unesa.ac.id', NULL, NULL, '$2y$12$dMJ/eesiP.YUD4RPvpoipOqk76TnddnNr0NlbdXTZEGQRdX3REt/K', NULL, '2026-10-16 17:40:50', '2026-10-16 17:40:50'),
	(7, 'Asmunin', 'asmunin@unesa.ac.id', NULL, NULL, '$2y$12$btI/pf4SAVozaURcKqrKae4RiWWgDM1C3LJCgmKkl7zAN54f/rv2W', NULL, '2026-10-16 17:40:50', '2026-10-16 17:40:50'),
	(8, 'Cendra Putra, Ph.D', 'cendra.putra@unesa.ac.id', NULL, NULL, '$2y$12$im6DzRdhIHAeODGzYvG1quuwm2wXoI37smVD4t.6nnPokSS5PPGbi', NULL, '2026-10-16 17:40:50', '2026-10-16 17:40:50'),
	(9, 'Dwi Fatrianto Suyatno', 'dwi.fatrianto@unesa.ac.id', NULL, NULL, '$2y$12$pzfFjkMFrlKdoVYDMw0EVOowlEL5ZhEa792487Zm.nTOs55jJEuHq', NULL, '2026-10-16 17:40:51', '2026-10-16 17:40:51'),
	(10, 'Dosen Pengampu', 'dosen.pengampu@unesa.ac.id', NULL, NULL, '$2y$12$oylrLEAQxuxTIJdXWHmxkuxeTIZFEAbTD06OsYwRLDqOwXDEC2EQm', NULL, '2026-10-16 17:40:51', '2026-10-16 17:40:51'),
	(11, '001_TATA IVANKA', 'mhs001@mhs.unesa.ac.id', NULL, NULL, '$2y$12$/5w2oRoICi8jaxOcB8K49euwRFQGgymw2f8GMOG.Fx0THaXH7/Yiu', NULL, '2026-10-16 17:40:51', '2026-10-16 17:40:51'),
	(12, '002_YOHANA NOVI', 'mhs002@mhs.unesa.ac.id', NULL, NULL, '$2y$12$Uo4u7xGRbOPJQauM.W6MNOtDxUEyhLH3ChL8BaUgr.pBRxWTOkLvi', NULL, '2026-10-16 17:40:52', '2026-10-16 17:40:52'),
	(13, '004_MUSA PANJAITAN', 'mhs003@mhs.unesa.ac.id', NULL, NULL, '$2y$12$nFWKtz9kfn/O2BPunVQ2aOepUIIafdF2TtwI/wOyaZ4A2iej8cRw6', NULL, '2026-10-16 17:40:52', '2026-10-16 17:40:52'),
	(14, '005_Naila Zazkia Rizqina', 'mhs004@mhs.unesa.ac.id', NULL, NULL, '$2y$12$o1pL9rHij5NcZ0gGFLlZC.5P7kfjeHlx/2nXxn6WtnhRvs5kKba2a', NULL, '2026-10-16 17:40:53', '2026-10-16 17:40:53'),
	(15, '006_FERISCA APRILIA PUTRI', 'mhs005@mhs.unesa.ac.id', NULL, NULL, '$2y$12$sq9EK.tp3Q05nFgtirHVTew5b6z/LUHJzcTrWPYdXku5rANn0jaw2', NULL, '2026-10-16 17:40:53', '2026-10-16 17:40:53'),
	(16, '006_Fitri Aisyah Ramadani', 'mhs006@mhs.unesa.ac.id', NULL, NULL, '$2y$12$1o/NcNXgt1TrXNLvSeOLROCNZi0ZmZfANKKgz3fmMwwOIFHcYNi5W', NULL, '2026-10-16 17:40:53', '2026-10-16 17:40:53'),
	(17, '007_ SINTA AFIFAH KHOIRUN', 'mhs007@mhs.unesa.ac.id', NULL, NULL, '$2y$12$FRsvevgHvASVXesMjqAuQuy9zyg59XbVUtsyKZ9.4XD5VgW7dvrAe', NULL, '2026-10-16 17:40:54', '2026-10-16 17:40:54'),
	(18, 'savana', 'savana123@gmail.com', NULL, NULL, '$2y$12$LKpChSgmak12Ybv.kCGeyeZtx.gsny8smMBcO9a1yn8l0SkoGT6u6', NULL, '2026-10-18 13:28:22', '2026-10-18 13:28:22'),
	(19, 'alif', 'akunalif123@gmail.com', NULL, NULL, '$2y$12$6bMhao9BfEucMawFZNOvr.QialT3SOJFKtYXmvqMBVOgb8RCc8s0i', NULL, '2026-10-18 17:31:04', '2026-10-18 17:31:04'),
	(20, 'fauzi', 'ahmadfauzi@gmail.com', NULL, NULL, '$2y$12$U0FtY/DSq11fx9JnAS7OwOmWFbulu9VvPmhD9ud8EhPRcpKayR1oW', NULL, '2026-10-19 03:34:19', '2026-10-19 03:34:19');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
