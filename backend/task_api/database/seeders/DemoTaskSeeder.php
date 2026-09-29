<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DemoTaskSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::query()->firstOrCreate(
            ['email' => 'demo@example.test'],
            ['name' => 'Pengguna Demo', 'password' => Hash::make('DemoTask2026!')]
        );

        $items = [
            ['Menyusun laporan', 'pending', '2026-10-15'],
            ['Membaca referensi', 'completed', '2026-10-12'],
            ['Menyiapkan presentasi', 'pending', '2026-10-18'],
            ['Memeriksa catatan', 'completed', '2026-10-10'],
            ['Merapikan dokumentasi', 'pending', '2026-10-20'],
        ];

        foreach ($items as [$title, $status, $dueDate]) {
            $user->tasks()->firstOrCreate(
                ['title' => $title],
                [
                    'description' => null,
                    'status' => $status,
                    'priority' => 'medium',
                    'due_date' => $dueDate,
                ]
            );
        }
    }
}
