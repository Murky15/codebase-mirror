/* TODO: PRs
  - [ ] `Clay_SetExternalScrollHandlingEnabled` is not included in the header portion of clay.h
  - [ ] Error in the clay.h CLAY macro example code (CLAY_ID is in the wrong spot)
  - [ ] Line 4077 of clay.h, incorrect CLAY_WASM_EXPORT name
*/

// NOTE: Handwritten macro API

Clay_BorderOutside :: inline (width: u16) -> Clay_BorderWidth {
  return {width, width, width, width, 0};
}

Clay_BorderAll :: inline (width: u16) -> Clay_BorderWidth {
  return {width, width, width, width, width};
}

Clay_CornerRadiusAll :: inline (radius: float) -> Clay_CornerRadius {
  return {radius, radius, radius, radius};
}

Clay_PaddingAll :: inline (padding: u16) -> Clay_Padding {
  return {padding, padding, padding, padding};
}

Clay_SizingFit :: inline (minMax := Clay_SizingMinMax.{}) -> Clay_SizingAxis {
  return {size = {minMax = minMax}, type = .FIT};
}

Clay_SizingGrow :: inline (minMax := Clay_SizingMinMax.{}) -> Clay_SizingAxis {
  return {size = {minMax = minMax}, type = .GROW};
}

Clay_SizingFixed :: inline (fixedSize: float) -> Clay_SizingAxis {
  return {size = {minMax = {fixedSize, fixedSize}}, type = .FIXED};
}

Clay_SizingPercent :: inline (percentOfParent: float) -> Clay_SizingAxis {
  return {size = {percent = percentOfParent}, type = .PERCENT};
}

Clay_Id :: inline (label: string, index: u32 = 0) -> Clay_ElementId {
  return Clay__HashString(Clay_MakeString(label), index);
}

Clay_IdLocal :: inline (label: string, index: u32 = 0) -> Clay_ElementId {
  return Clay__HashStringWithOffset(Clay_MakeString(label), index, Clay_GetOpenElementId());
}

Clay_MakeString :: inline (str: string) -> Clay_String {
  return {chars = str.data, length = cast(s32)str.count};
}

Clay_GetString :: inline (str: Clay_String) -> string {
  return {str.length, str.chars};
}

Clay_UI :: (id: Clay_ElementId, config: Code, body := #code,null, call := #caller_code) #expand {
  patched_config :: #run patch_element_declaration_config(config);

  Clay__OpenElementWithId(id);
  Clay__ConfigureOpenElement(#insert,scope(call) patched_config);
  #insert body;
  Clay__CloseElement();
}

Clay_UI :: (config: Code, body := #code,null, call := #caller_code) #expand {
  patched_config :: #run patch_element_declaration_config(config);

  Clay__OpenElement();
  Clay__ConfigureOpenElement(#insert,scope(call) patched_config);
  #insert body;
  Clay__CloseElement();
}

Clay_Text :: (text: string, config := Clay_TextElementConfig.{}) #expand {
  wrapped := Clay_MakeString(text);
  #if is_constant(text) wrapped.isStaticallyAllocated = true;
  Clay__OpenTextElement(wrapped, config);
}

#load "clay_bindings.jai";

#scope_module

// NOTE: Clay's API heavily relies on C's textual replacement macros.
// The expected behavior is that when you use the `CLAY` macro to create a new element,
// that new element is pushed onto Clay's internal element stack as the current open element
// *before* the element declaration is evaluated. Jai (sensibly) evaluates all arguments before
// expanding the macro, but this means that any clay function (`GetScrollOffset`, `OnHover`, etc.)
// called while filling out a normal `ElementDeclaration` parameter will now be broken.
// This is why bindings to other languages like Odin replace this single macro call with a sequence
// of function calls to enforce the ordering. My solution instead is to take the `ElementDeclaration`
// argument as a `Code` instead that we can #insert *after* we open the new element.

// This function simply stitches the proper type into that argument if the user provides
// an anonymous struct literal.
patch_element_declaration_config :: (untyped_literal: Code) -> Code {
  using Compiler :: #import "Compiler";

  untyped_node := cast(*Code_Literal) compiler_get_nodes(untyped_literal);
  if untyped_node.kind != .LITERAL return untyped_literal;
  if untyped_node.value_type != .STRUCT {
    compiler_report("This literal must be of struct type `Clay_ElementDeclaration`", make_location(untyped_node));
  }

  TYPED_LITERAL :: #code Clay_ElementDeclaration.{};
  typed_node := cast(*Code_Literal) compiler_get_nodes(TYPED_LITERAL);

  untyped_node.type = typed_node.type;
  untyped_node.struct_literal_info.type_expression = typed_node.struct_literal_info.type_expression;

  return compiler_get_code(untyped_node);
}