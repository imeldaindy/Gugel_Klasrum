<?php

namespace Database\Seeders;

use App\Models\Assignment;
use App\Models\Course;
use App\Models\Post;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Data awal = data dummy di aplikasi Flutter. Sandi semua akun: "password".
 */
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Akun yang sama dengan daftar akun di aplikasi (id 1-5).
        $accounts = collect([
            ['228_ Alif Muhammad Hafizh', '24051214228@mhs.unesa.ac.id'],
            ['Alf Game', 'alfgame321@gmail.com'],
            ['Alif Muhammad', 'alifscc0311@gmail.com'],
            ['soto cak ipin', 'sotoayamcakipinktt@gmail.com'],
            ['Alif Hafizh', 'alifmhafizh0311@gmail.com'],
        ])->map(fn ($a) => User::create([
            'name' => $a[0], 'email' => $a[1], 'password' => 'password',
        ]));

        $teacher = fn (string $name, string $email) => User::create([
            'name' => $name, 'email' => $email, 'password' => 'password',
        ]);
        $rahadian = $teacher('Rahadian Bisma', 'rahadian.bisma@unesa.ac.id');
        $asmunin = $teacher('Asmunin', 'asmunin@unesa.ac.id');
        $cendra = $teacher('Cendra Putra, Ph.D', 'cendra.putra@unesa.ac.id');
        $dwi = $teacher('Dwi Fatrianto Suyatno', 'dwi.fatrianto@unesa.ac.id');
        $dosen = $teacher('Dosen Pengampu', 'dosen.pengampu@unesa.ac.id');

        // Teman sekelas di kelas Audit Sistem Informasi.
        $classmates = collect([
            '001_TATA IVANKA', '002_YOHANA NOVI', '004_MUSA PANJAITAN',
            '005_Naila Zazkia Rizqina', '006_FERISCA APRILIA PUTRI',
            '006_Fitri Aisyah Ramadani', '007_ SINTA AFIFAH KHOIRUN',
        ])->map(fn ($name, $i) => User::create([
            'name' => $name,
            'email' => sprintf('mhs%03d@mhs.unesa.ac.id', $i + 1),
            'password' => 'password',
        ]));

        $defs = [
            ['Audit Sistem Informasi', null, $rahadian, 'audit001'],
            ['Literasi Digital187', 'Rabu, 07.00 - Selesai', $asmunin, 'literas2'],
            ['KSI-G', null, $cendra, 'ksig0003'],
            ['Manajemen Layanan Pelanggan', 'S1 SI MLP03 RABU Jam 07:00 - 12:00 A10.', $dwi, 'mlp03rab'],
            ['Keamanan sistem informasi', '2024', $dosen, 'keamanan'],
            ['2024 G - Analisis dan Perancangan Sistem', null, $dosen, 'apsi2024'],
            ['SBD 2024G', null, $dosen, 'sbd2024g'],
        ];

        $courses = [];
        foreach ($defs as [$name, $section, $owner, $code]) {
            $c = Course::create([
                'name' => $name,
                'section' => $section,
                'code' => $code,
                'teacher_id' => $owner->id,
            ]);
            $c->members()->attach($owner->id, ['role' => 'teacher']);
            foreach ($accounts as $u) {
                $c->members()->attach($u->id, ['role' => 'student']);
            }
            $courses[] = $c;
        }

        $audit = $courses[0];
        foreach ($classmates as $u) {
            $audit->members()->attach($u->id, ['role' => 'student']);
        }

        Post::create([
            'course_id' => $audit->id,
            'user_id' => $rahadian->id,
            'content' => 'Tugas Audit Program dan Audit Plan',
            'is_assignment' => true,
            'created_at' => '2026-10-15 11:31:00',
            'updated_at' => '2026-10-15 11:31:00',
        ]);
        Post::create([
            'course_id' => $audit->id,
            'user_id' => $rahadian->id,
            'content' => "Tugas Audit plan. silahkan dikumpulkan disini.\n"
                ."cukup ketua kelompok yang mengumpulkan,\nTuliskan\n\n"
                ."• Objek Audit/Standart\n• nama anggota,\n• nim,\n• kelas",
            'is_assignment' => false,
            'created_at' => '2026-10-15 08:54:00',
            'updated_at' => '2026-10-15 08:54:00',
        ]);

        Assignment::create([
            'course_id' => $audit->id,
            'title' => 'Tugas Audit Program dan Audit Plan',
            'description' => 'Kumpulkan audit plan kelompok. Cukup ketua kelompok yang mengumpulkan.',
            'points' => 100,
            'deadline' => '2026-10-30 23:59:00',
        ]);

        foreach ($accounts as $u) {
            DB::table('notifications')->insert([
                [
                    'user_id' => $u->id,
                    'course_id' => $audit->id,
                    'title' => 'Tugas baru: Tugas Audit Program dan Audit Plan',
                    'body' => 'Audit Sistem Informasi',
                    'created_at' => '2026-10-15 11:31:00',
                    'updated_at' => '2026-10-15 11:31:00',
                ],
                [
                    'user_id' => $u->id,
                    'course_id' => $audit->id,
                    'title' => 'Rahadian Bisma memposting pengumuman baru',
                    'body' => 'Audit Sistem Informasi',
                    'created_at' => '2026-10-15 08:54:00',
                    'updated_at' => '2026-10-15 08:54:00',
                ],
            ]);
        }
    }
}
