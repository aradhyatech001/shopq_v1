<?php

namespace App\Http\Controllers;

use App\Models\ProductType;
use App\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class ProductTypeController extends Controller
{
    private function normalizeTypeList(?string $types): array
    {
        return collect(explode(',', (string) $types))
            ->map(fn($type) => trim($type))
            ->filter()
            ->unique()
            ->values()
            ->all();
    }

    private function updateProductsForRenamedType(string $oldName, string $newName): void
    {
        Product::whereRaw('FIND_IN_SET(?, types)', [$oldName])
            ->chunkById(100, function ($products) use ($oldName, $newName) {
                foreach ($products as $product) {
                    $types = collect($this->normalizeTypeList($product->types))
                        ->map(fn($type) => $type === $oldName ? $newName : $type)
                        ->unique()
                        ->values()
                        ->implode(',');

                    $product->update(['types' => $types]);
                }
            });
    }

    private function removeTypeFromProducts(string $name): void
    {
        Product::whereRaw('FIND_IN_SET(?, types)', [$name])
            ->chunkById(100, function ($products) use ($name) {
                foreach ($products as $product) {
                    $types = collect($this->normalizeTypeList($product->types))
                        ->reject(fn($type) => $type === $name)
                        ->values()
                        ->implode(',');

                    $product->update(['types' => $types]);
                }
            });
    }

    /** GET /api/product-types */
    public function view()
    {
        $types = ProductType::orderBy('position')->orderBy('id')->get(['id', 'name', 'position']);
        return response()->json(['success' => true, 'data' => $types]);
    }

    /** POST /api/product-types/add */
    public function add(Request $request)
    {
        $name     = trim($request->input('name', ''));
        $position = (int) $request->input('position', 0);

        if (!$name) {
            return response()->json(['success' => false, 'message' => 'Name is required']);
        }
        if (ProductType::whereRaw('LOWER(name) = ?', [mb_strtolower($name)])->exists()) {
            return response()->json(['success' => false, 'message' => 'Type already exists']);
        }

        // Default position: append at end
        if ($position === 0) {
            $max = ProductType::max('position') ?? 0;
            $position = $max + 1;
        }

        $type = ProductType::create(['name' => $name, 'position' => $position]);
        return response()->json(['success' => true, 'message' => 'Type added', 'data' => $type]);
    }

    /** POST /api/product-types/edit */
    public function edit(Request $request)
    {
        $id       = $request->input('id');
        $name     = trim($request->input('name', ''));
        $position = $request->has('position') ? (int) $request->input('position') : null;

        if (!$id || !$name) {
            return response()->json(['success' => false, 'message' => 'id and name required']);
        }
        $type = ProductType::find($id);
        if (!$type) {
            return response()->json(['success' => false, 'message' => 'Type not found']);
        }
        if (ProductType::whereRaw('LOWER(name) = ?', [mb_strtolower($name)])
            ->where('id', '!=', $id)
            ->exists()) {
            return response()->json(['success' => false, 'message' => 'Type already exists']);
        }

        $oldName = $type->name;

        $updates = ['name' => $name];
        if ($position !== null) {
            $updates['position'] = $position;
        }

        DB::transaction(function () use ($type, $updates, $oldName, $name) {
            $type->update($updates);

            if ($oldName !== $name) {
                $this->updateProductsForRenamedType($oldName, $name);
            }
        });

        return response()->json(['success' => true, 'message' => 'Type updated']);
    }

    /** POST /api/product-types/delete */
    public function delete(Request $request)
    {
        $id   = $request->input('id');
        $type = ProductType::find($id);
        if (!$type) {
            return response()->json(['success' => false, 'message' => 'Type not found']);
        }
        $name = $type->name;

        DB::transaction(function () use ($type, $name) {
            $type->delete();
            $this->removeTypeFromProducts($name);
        });

        return response()->json(['success' => true, 'message' => 'Type deleted']);
    }

    /**
     * POST /api/product-types/reorder
     * Body: ordered_ids = [3, 1, 2, ...]  (array of ids in desired order)
     */
    public function reorder(Request $request)
    {
        $ids = $request->input('ordered_ids', []);
        if (empty($ids) || !is_array($ids)) {
            return response()->json(['success' => false, 'message' => 'ordered_ids array required']);
        }

        DB::transaction(function () use ($ids) {
            foreach ($ids as $position => $id) {
                ProductType::where('id', (int) $id)->update(['position' => $position + 1]);
            }
        });

        return response()->json(['success' => true, 'message' => 'Order saved']);
    }
}
