<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Http\Resources\TaskResource;
use App\Models\Task;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class TaskController extends Controller
{
    private function demoUser(): User
    {
        return User::query()->where('email', 'demo@example.test')->firstOrFail();
    }

    public function index(): AnonymousResourceCollection
    {
        $tasks = $this->demoUser()->tasks()->orderBy('id')->get();

        return TaskResource::collection($tasks);
    }

    public function store(StoreTaskRequest $request): JsonResponse
    {
        $task = $this->demoUser()->tasks()->create($request->validated());

        return (new TaskResource($task))->response()->setStatusCode(201);
    }

    public function show(int $id): TaskResource
    {
        $task = $this->demoUser()->tasks()->findOrFail($id);

        return new TaskResource($task);
    }

    public function update(UpdateTaskRequest $request, int $id): TaskResource
    {
        $task = $this->demoUser()->tasks()->findOrFail($id);
        $task->update($request->validated());

        return new TaskResource($task->refresh());
    }

    public function destroy(int $id): Response
    {
        $task = $this->demoUser()->tasks()->findOrFail($id);
        $task->delete();

        return response()->noContent();
    }
}
