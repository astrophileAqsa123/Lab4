@extends('layouts.app')

@section('content')

<h1>Products</h1>

<a href="{{ route('products.create') }}" class="btn btn-primary mb-3">
    Add Product
</a>

<table class="table table-bordered">
<tr>
    <th>ID</th>
    <th>Name</th>
    <th>Price</th>
    <th>Quantity</th>
    <th>Actions</th>
</tr>

@foreach($products as $product)
<tr>
    <td>{{ $product->id }}</td>
    <td>{{ $product->name }}</td>
    <td>{{ $product->price }}</td>
    <td>{{ $product->quantity }}</td>

    <td>
        <a href="{{ route('products.show',$product) }}" class="btn btn-info btn-sm">View</a>

        <a href="{{ route('products.edit',$product) }}" class="btn btn-warning btn-sm">Edit</a>

        <form action="{{ route('products.destroy',$product) }}" method="POST" style="display:inline">
            @csrf
            @method('DELETE')
            <button class="btn btn-danger btn-sm">Delete</button>
        </form>
    </td>
</tr>
@endforeach

</table>

@endsection
