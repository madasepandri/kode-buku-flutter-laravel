<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class IndexTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'search' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', Rule::in(['pending', 'completed'])],
            'priority' => ['nullable', Rule::in(['low', 'medium', 'high'])],
            'page' => ['nullable', 'integer', 'min:1'],
        ];
    }
}
