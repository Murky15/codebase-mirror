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

/*
Clay_UI :: (element: Clay_ElementDeclaration, code := #code,null) #expand {
  Clay__OpenElement();
  Clay__ConfigureOpenElement(element);
  #insert code;
  Clay__CloseElement();
}

Clay_UI :: (id: Clay_ElementId, element: Clay_ElementDeclaration, code := #code,null) #expand {
  Clay__OpenElementWithId(id);
  Clay__ConfigureOpenElement(element);
  #insert code;
  Clay__CloseElement();
}
*/

configure_open_element_proc :: type_of(Clay__ConfigureOpenElement)
Clay_UI :: (id: Clay_ElementId) -> configure_open_element_proc {
  Clay__OpenElementWithId(id);
  return Clay__ConfigureOpenElement;
}

for_expansion :: (proc: configure_open_element_proc, body: Code, flags: For_Flags) #expand {
  #assert flags == 0;
  #insert body;
  Clay__CloseElement();
}

Clay_Text :: inline ($$text: string, config := Clay_TextElementConfig.{}) {
  wrapped := Clay_MakeString(text);
  #if is_constant(text) wrapped.isStaticallyAllocated = true;
  Clay__OpenTextElement(wrapped, config);
}

#load "clay_bindings.jai";