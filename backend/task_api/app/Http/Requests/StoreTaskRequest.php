<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreTaskRequest extends FormRequest
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
            'status' => ['sometimes', Rule::in(['pending', 'completed'])],
            'priority' => ['sometimes', Rule::in(['low', 'medium', 'high'])],
        ];
    }
}
