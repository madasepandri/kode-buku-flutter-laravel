<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\IndexTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Http\Resources\TaskResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class TaskController extends Controller
{
    public function index(IndexTaskRequest $request): AnonymousResourceCollection
    {
        $input = $request->validated();
        $query = $request->user()->tasks();
        $search = trim($input['search'] ?? '');
        if ($search !== '') {
            $query->where('title', 'like', '%'.$search.'%');
        }
        if (! empty($input['status'])) {
            $query->where('status', $input['status']);
        }
        if (! empty($input['priority'])) {
            $query->where('priority', $input['priority']);
        }
        $tasks = $query->orderBy('id')->paginate(10)->withQueryString();

        return TaskResource::collection($tasks);
    }

    public function store(StoreTaskRequest $request): JsonResponse
    {
        $task = $request->user()->tasks()->create($request->validated());

        return (new TaskResource($task->refresh()))->response()->setStatusCode(201);
    }

    public function show(Request $request, int $id): TaskResource
    {
        $task = $request->user()->tasks()->findOrFail($id);

        return new TaskResource($task);
    }

    public function update(UpdateTaskRequest $request, int $id): TaskResource
    {
        $task = $request->user()->tasks()->findOrFail($id);
        $task->update($request->validated());

        return new TaskResource($task->refresh());
    }

    public function destroy(Request $request, int $id): Response
    {
        $task = $request->user()->tasks()->findOrFail($id);
        $task->delete();

        return response()->noContent();
    }
}

