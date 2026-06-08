<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Rol;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UsuarioController extends Controller
{
    public function index()
    {
        $usuarios = User::with('rol')
            ->orderBy('id_usuario', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $usuarios
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nombres' => 'required|string|max:150',
            'username' => 'required|string|max:50|unique:usuarios,username',
            'password' => 'required|string|min:4',
            'id_rol' => 'required|exists:roles,id_rol',
            'estado' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->all();
        $data['password'] = Hash::make($request->password);
        if (!isset($data['estado'])) $data['estado'] = true;

        $usuario = User::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Usuario creado con éxito',
            'data' => $usuario->load('rol')
        ], 201);
    }

    public function show($id)
    {
        $usuario = User::with('rol')->find($id);

        if (!$usuario) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no encontrado'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $usuario
        ]);
    }

    public function update(Request $request, $id)
    {
        $usuario = User::find($id);

        if (!$usuario) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no encontrado'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nombres' => 'required|string|max:150',
            'username' => 'required|string|max:50|unique:usuarios,username,' . $id . ',id_usuario',
            'password' => 'nullable|string|min:4',
            'id_rol' => 'required|exists:roles,id_rol',
            'estado' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['nombres', 'username', 'id_rol', 'estado']);
        
        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $usuario->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Usuario actualizado con éxito',
            'data' => $usuario->load('rol')
        ]);
    }

    public function destroy($id)
    {
        $usuario = User::find($id);

        if (!$usuario) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no encontrado'
            ], 404);
        }

        // Si el usuario es el administrador principal (id=1), impedir eliminación
        if ($id == 1) {
            return response()->json([
                'success' => false,
                'message' => 'No se puede desactivar o eliminar al Administrador General'
            ], 400);
        }

        // Si tiene ventas o movimientos registrados, desactivarlo en lugar de borrarlo
        $tieneVentas = $usuario->ventas()->count() > 0;
        $tieneMovimientos = $usuario->movimientosInventario()->count() > 0;

        if ($tieneVentas || $tieneMovimientos) {
            $usuario->update(['estado' => false]);
            return response()->json([
                'success' => true,
                'message' => 'El usuario posee historial de operaciones. Se ha desactivado en vez de eliminarse de forma permanente.'
            ]);
        }

        $usuario->delete();

        return response()->json([
            'success' => true,
            'message' => 'Usuario eliminado de forma permanente con éxito'
        ]);
    }

    public function getRoles()
    {
        $roles = Rol::all();
        return response()->json([
            'success' => true,
            'data' => $roles
        ]);
    }
}
