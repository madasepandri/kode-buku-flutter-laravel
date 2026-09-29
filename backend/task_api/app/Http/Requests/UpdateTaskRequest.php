<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'due_date' => ['required', 'date_format:Y-m-d'],
            'status' => ['required', Rule::in(['pending', 'completed'])],
            'priority' => ['required', Rule::in(['low', 'medium', 'high'])],
        ];
    }
}
