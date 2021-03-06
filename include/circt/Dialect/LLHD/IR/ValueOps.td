//===- ValueOps.td - LLHD value operations -----------------*- tablegen -*-===//
//
// This describes the MLIR ops for LLHD value creation.
//
//===----------------------------------------------------------------------===//

def LLHD_ConstOp : LLHD_Op<"const", [ConstantLike, NoSideEffect]> {
  let summary = "Introduce a new constant.";
  let description = [{
    The `llhd.const` instruction introduces a new constant value as an
    SSA-operator.
    Legal types are integers and time. Note: Signals
    are not legal to define using `llhd.const`, use the `llhd.sig`
    instruction for that.

    Syntax:

    ```
    const-op ::= ssa-id `=`
      `llhd.const` attribute-value attr-dict `:` result-type
    ```

    Example:

    ```mlir
    %0 = llhd.const 1 : i64
    %1 = llhd.const #llhd.time<1ns, 2d, 3d> : !llhd.time
    ```
  }];

  let arguments = (ins AnyAttr: $value);
  let results = (outs AnyTypeOf<[AnySignlessInteger, LLHD_TimeType]>: $out);

  let hasFolder = 1;
}

def LLHD_VecOp : LLHD_Op<"vec", [
    NoSideEffect,
    TypesMatchWith<
      "types and number of 'values' have to match the length and type of the "
      "'result' vector",
      "result", "values",
      "std::vector<Type>($_self.cast<ShapedType>().getNumElements(), "
      "$_self.cast<ShapedType>().getElementType())">
  ]> {
  let summary = "Create a vector from a list of values.";
  let description = [{
    The `llhd.vec` operation allows to create a vector from a list of
    SSA-values. This allows for more flexibility compared to only using
    `std.constant` and the vector dialect operations.

    Example:

    ```mlir
    %c1 = llhd.const 1 : i32
    %c2 = llhd.const 2 : i32
    %c3 = llhd.const 3 : i32
    %vec = llhd.vec %c1, %c2, %c3 : vector<3xi32>
    %elem = vector.extractelement %vec[%c1 : i32] : vector<3xi32>
    ```
  }];

  let arguments = (ins Variadic<AnyType>: $values);
  let results = (outs AnyVector: $result);

  let assemblyFormat = "$values attr-dict `:` type($result)";
}

def LLHD_TupleOp : LLHD_Op<"tuple", [
    NoSideEffect,
    TypesMatchWith<
      "types of 'values' have to match the type of the corresponding 'result' "
      "tuple element",
      "result", "values",
      "$_self.cast<TupleType>().getTypes()">
  ]> {
  let summary = "Create a tuple from a list of values.";
  let description = [{
    The `llhd.tuple` operation creates a tuple from a list of SSA-values.

    Example:

    ```mlir
    %c1 = llhd.const 1 : i32
    %c2 = llhd.const 2 : i2
    %sig = llhd.sig "sig_name" %c1 : i32
    %vec = constant dense<[1, 2]> : vector<2xi32>
    %tuple = llhd.tuple %c1, %c2, %vec, %sig :
      tuple<i32, i2, vector<2xi32>, !llhd.sig<i32>>
    ```
  }];

  let arguments = (ins Variadic<AnyType>: $values);
  let results = (outs AnyTuple: $result);

  let assemblyFormat = "$values attr-dict `:` type($result)";
}
