<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdvancedFeaturesTest extends TestCase
{
    use RefreshDatabase;

    public function test_pagination_combines_filters_and_isolates_owner(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        foreach (range(1, 12) as $i) {
            $owner->tasks()->create(['title' => "Laporan $i", 'description' => '',
                'status' => 'pending', 'priority' => 'high', 'due_date' => '2026-10-01']);
        }
        $other->tasks()->create(['title' => 'Laporan lain', 'description' => '',
            'status' => 'pending', 'priority' => 'high', 'due_date' => '2026-10-01']);
        Sanctum::actingAs($owner);
        $this->getJson('/api/tasks?search=Laporan&status=pending&priority=high')
            ->assertOk()->assertJsonCount(10, 'data')->assertJsonPath('meta.total', 12);
        $this->getJson('/api/tasks?search=Laporan&status=pending&priority=high&page=2')
            ->assertOk()->assertJsonCount(2, 'data')->assertJsonPath('meta.current_page', 2);
        $this->getJson('/api/tasks?status=invalid')->assertUnprocessable();
    }

    public function test_edit_profile_updates_current_user_and_rejects_duplicate_email(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        Sanctum::actingAs($owner);
        $this->putJson('/api/user', ['name' => 'Nama baru', 'email' => $owner->email])
            ->assertOk()->assertJsonPath('data.name', 'Nama baru');
        $this->putJson('/api/user', ['name' => 'Ditolak', 'email' => $other->email])
            ->assertUnprocessable();
        $this->assertDatabaseHas('users', ['id' => $owner->id, 'name' => 'Nama baru']);
    }

    public function test_avatar_is_replaced_only_after_valid_upload(): void
    {
        Storage::fake('public');
        $owner = User::factory()->create();
        Sanctum::actingAs($owner);
        $this->post('/api/user/avatar', ['avatar' => UploadedFile::fake()->image('first.png')],
            ['Accept' => 'application/json'])->assertOk()->assertJsonStructure(['data' => ['avatar_url']]);
        $first = $owner->refresh()->avatar;
        Storage::disk('public')->assertExists($first);
        $this->post('/api/user/avatar', ['avatar' => UploadedFile::fake()->create('bad.txt')],
            ['Accept' => 'application/json'])->assertUnprocessable();
        $this->assertSame($first, $owner->refresh()->avatar);
        $this->post('/api/user/avatar', ['avatar' => UploadedFile::fake()->image('second.png')],
            ['Accept' => 'application/json'])->assertOk();
        Storage::disk('public')->assertMissing($first);
        Storage::disk('public')->assertExists($owner->refresh()->avatar);
    }

    public function test_profile_and_avatar_require_authentication(): void
    {
        $this->putJson('/api/user', ['name' => 'Guest', 'email' => 'guest@example.test'])
            ->assertUnauthorized();
        $this->postJson('/api/user/avatar')->assertUnauthorized();
    }
}
