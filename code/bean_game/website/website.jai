COLOR_BLACK     :: #run color_from_hex(0x0a100d); // Onyx
COLOR_LIGHT     :: #run color_from_hex(0xd6d5c9); // Bone
COLOR_LIGHT_ALT :: #run color_from_hex(0xb9baa3); // Ash Grey
COLOR_RED       :: #run color_from_hex(0x902923); // Chestnut
COLOR_RED_ALT   :: #run color_from_hex(0xa22c29); // Brown Red

window_width:  s32 = 1024;
window_height: s32 = 768;

fonts: [] *TTF_Font;

color_from_hex :: inline (hex: u32, alpha: u8 = 255) -> Clay_Color {
  r := cast(u8) (hex & 0xff0000) >> 16;
  g := cast(u8) (hex & 0x00ff00) >> 8;
  b := cast(u8) (hex & 0x0000ff);

  return {xx r, xx g, xx b, xx alpha};
}

handle_clay_errors :: (error_data: Clay_ErrorData) #c_call {
  // TODO: Fix this
  context_pointer := cast(*#Context) error_data.userData;
  push_context context_pointer {
    log("%", to_string(error_data.errorText.chars));
  }
}

sdl3_measure_text :: (text: Clay_StringSlice, config: *Clay_TextElementConfig, userData: *void) -> Clay_Dimensions #c_call {
  fonts := cast(*[] *TTF_Font, userData).*;
  font := fonts[config.fontId];
  w, h: s32;

  desired_font_size := cast(float) config.fontSize;
  if TTF_GetFontSize(font) != desired_font_size TTF_SetFontSize(font, desired_font_size);
  TTF_GetStringSize(font, text.chars, xx text.length, *w, *h);

  return {xx w, xx h};
}

divider :: (width_percent: float, color := COLOR_BLACK) {
  Clay_UI({layout = {sizing = {Clay_SizingPercent(width_percent), Clay_SizingFixed(5)}}, backgroundColor = color, cornerRadius = Clay_CornerRadiusAll(8)});
}

main_title_size: Clay_Dimensions;

header :: () {
  Clay_UI(Clay_Id("Header"), {layout = {sizing = {width = Clay_SizingGrow()}, childGap = 16, childAlignment = {x = .CENTER}, layoutDirection = .TOP_TO_BOTTOM}}, #code {
    small_text_baseline_padding := Clay_Padding.{bottom = 10};
    Clay_UI(Clay_Id("HeaderContent"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, childGap = 16}}, #code {
      main_title_string := "Bean Game";
      main_title_config := Clay_TextElementConfig.{textColor = COLOR_BLACK, fontId = FONTFACE_TANKER_REGULAR, fontSize = 60, wrapMode = .NONE};
      if main_title_size.width == 0 {
        main_title_size = sdl3_measure_text({length = xx main_title_string.count, chars = main_title_string.data}, *main_title_config, *fonts);
      }
      Clay_UI(Clay_Id("TitleContainer"), {layout = {sizing = {Clay_SizingFit({min = main_title_size.width}), Clay_SizingGrow()}, layoutDirection = .TOP_TO_BOTTOM}}, #code {
        Clay_Text("The", {textColor = COLOR_RED, fontId = FONTFACE_ARRAY_BOLDWIDE, fontSize = 40});
        Clay_Text(main_title_string, main_title_config);
      });
      Clay_UI(Clay_Id("AuthorContainer"), {layout = {sizing = {height = Clay_SizingGrow()}, padding = small_text_baseline_padding, childAlignment = {y = .BOTTOM}}}, #code {
        Clay_Text("By Gianni Bernardi", {textColor = COLOR_BLACK, fontId = FONTFACE_GEO_REGULAR, fontSize = 32});
      });
      Clay_UI(Clay_Id("SocialsContainer"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, padding = small_text_baseline_padding, childAlignment = {.RIGHT, .BOTTOM}}}, #code {
        Clay_Text("Put socials here", {textColor = COLOR_BLACK, fontSize = 24});
      });
    });
    divider(1, COLOR_RED);
  });
}

main :: () {
  window := SDL_CreateWindow("Bean Game Website", window_width, window_height, SDL_WINDOW_RESIZABLE);
  renderer := SDL_CreateRenderer(window, null);

  assert(TTF_Init(), "Failed to initialize sdl3_ttf!");
  text_engine := TTF_CreateRendererTextEngine(renderer);
  fonts = init_fonts();

  required_memory := Clay_MinMemorySize();
  clay_arena := Clay_CreateArenaWithCapacityAndMemory(required_memory, alloc(required_memory));
  Clay_Initialize(clay_arena, {xx window_width, xx window_height}, {handle_clay_errors, *context});
  Clay_SetMeasureTextFunction(sdl3_measure_text, *fonts);

  clay_renderer_data := Clay_SDL3RendererData.{
    renderer,
    text_engine,
    fonts.data,
  };

  should_run := true;
  start := SDL_GetTicks();
  while should_run {
    reset_temporary_storage();

    end := SDL_GetTicks();
    dt := (end - start) / 1000.0;
    start = end;

    e: SDL_Event;
    while SDL_PollEvent(*e) {
      if cast(SDL_EventType) e.type == {
        case .SDL_EVENT_QUIT; should_run = false;

        case .SDL_EVENT_WINDOW_RESIZED;
          window_width, window_height = e.window.data1, e.window.data2;
          Clay_SetLayoutDimensions({xx window_width, xx window_height});
        case .SDL_EVENT_MOUSE_WHEEL;
          Clay_UpdateScrollContainers(true, {e.wheel.x, e.wheel.y}, dt);
      }
    }

    mouse_x, mouse_y: float;
    mouse_buttons := SDL_GetMouseState(*mouse_x, *mouse_y);
    Clay_SetPointerState({mouse_x, mouse_y}, cast(bool, mouse_buttons & 0x1));

    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);

    Clay_BeginLayout();
    defer {
      clay_render_commands := Clay_EndLayout(dt);
      SDL_Clay_RenderClayCommands(*clay_renderer_data, *clay_render_commands);
      SDL_RenderPresent(renderer);
    }

    Clay_UI(Clay_Id("OuterContainer"), {
      layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, padding = Clay_PaddingAll(16), layoutDirection = .TOP_TO_BOTTOM},
      backgroundColor = COLOR_LIGHT},
    #code {
      header();

      Clay_UI(Clay_Id("OuterScrollContainer"), {
        layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, padding = Clay_PaddingAll(16), childGap = 32, layoutDirection = .TOP_TO_BOTTOM},
        backgroundColor = COLOR_LIGHT,
        clip = {vertical = true, childOffset = Clay_GetScrollOffset()}},
      #code {
        log("%", Clay_GetScrollOffset());
        Clay_UI(Clay_Id("ButtonContainer"), {layout = {sizing = {width = Clay_SizingGrow()}, childGap = 32, padding = {0, 0, 10, 10}, childAlignment = {x = .CENTER}}}, #code {
          button_decl := Clay_ElementDeclaration.{
            layout = {sizing = {Clay_SizingFixed(140), Clay_SizingFixed(100)}, padding = Clay_PaddingAll(4), childAlignment = {.CENTER, .CENTER}},
            backgroundColor = COLOR_LIGHT, // NOTE: Transition to `COLOR_LIGHT_ALT` when hovered
            cornerRadius = Clay_CornerRadiusAll(6),
            border = {COLOR_RED_ALT, Clay_BorderOutside(4)}
          };
          button_text_config := Clay_TextElementConfig.{textColor = COLOR_BLACK, fontId = FONTFACE_TANKER_REGULAR, fontSize = 32, textAlignment = .CENTER};

          Clay_UI(Clay_Id("PlayOnlineButton"), button_decl, #code {
            Clay_Text("Play Online", button_text_config);
          });
          Clay_UI(Clay_Id("DownloadNowButton"), button_decl, #code {
            Clay_Text("Download Now", button_text_config);
          });
          Clay_UI(Clay_Id("CustomLevelsButton"), button_decl, #code {
            Clay_Text("Custom Levels", button_text_config);
          });
        });

        Clay_UI(Clay_Id("AboutContainer"), {layout = {sizing = {width = Clay_SizingGrow()}}}, #code {
          Clay_UI(Clay_Id("AboutTextContainer"), {
            layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, padding = Clay_PaddingAll(16), childGap = 16, childAlignment = {x = .CENTER}, layoutDirection = .TOP_TO_BOTTOM},
            backgroundColor = COLOR_LIGHT_ALT,
            cornerRadius = Clay_CornerRadiusAll(6),
            border = {COLOR_BLACK, Clay_BorderOutside(4)}},
          #code {
            Clay_UI(Clay_Id("AboutHeading"), {layout = {sizing = {width = Clay_SizingGrow()}, childAlignment = {.LEFT, .CENTER}}}, #code {
              Clay_Text("About", {textColor = COLOR_RED, fontId = FONTFACE_ARRAY_BOLDWIDE, fontSize = 40});
            });
            divider(0.75);
            Clay_Text(ABOUT_TEXT, {textColor = COLOR_BLACK, fontId = FONTFACE_NIPPO_REGULAR, fontSize = 20});
          });
        });

      });
    });
  }
}

ABOUT_TEXT_RAW :: #string EOF
Hello! My name is Gianni Bernardi. I am a student at the Binghamton University Watson college of Engineering and Applied Science, and I am also a recent graduate of Somers High School.
I have always been infatuated with computers, but I have only seriously gotten into programming since about 2021. I started off writing games for my friends during the COVID-19 lockdowns
while I was in middle school, one of them being the original Bean Game. Now I am a systems programmer. Not a webdev, and definitely not a graphic designer either (can you tell?).
I have experience with a variety of languages, but my go-tos are Jai and C. This game is written in Jai. In fact, this website is written in Jai!
My original goal for this game was to bring people together during a challenging time, but I lacked the proper skills to make something I was genuinely proud of. So that's
what this new game is, a gift to my younger self. The game I always wanted but couldn't make. I hope you have as much fun playing it as I did making it.
EOF
ABOUT_TEXT :: #run replace(ABOUT_TEXT_RAW, "\n", " ");

FONT_DIRECTORIES_TO_SEARCH :: string.[
  "W:/assets/bean_game/fonts/Geo",
  "W:/assets/bean_game/fonts/Array_Complete/Fonts/OTF",
  "W:/assets/bean_game/fonts/Nippo_Complete/Fonts/OTF",
  "W:/assets/bean_game/fonts/Tanker_Complete/Fonts/OTF",
  "W:/assets/bean_game/fonts/WorkSans_Complete/Fonts/OTF",
];
FONT_DEFAULT_SIZE :: 24;

init_fonts :: () -> [] *TTF_Font {
  #insert -> string {
    using Compiler :: #import "Compiler";
    using Util     :: #import "File_Utilities";

    faces: [..] string;
    builder: String_Builder;
    print_to_builder(*builder, "result := *TTF_Font.[\n");
    for dir: FONT_DIRECTORIES_TO_SEARCH {
      if it_index > 0 print_to_builder(*builder, "\n");

      for path: file_list(dir, recursive = false) {
        extension := path_extension(path);
        if extension != "ttf" && extension != "otf" continue;

        face_name := path_strip_extension(path_filename(path));
        face_name_formatted := to_upper_copy(face_name);
        replace_chars(face_name_formatted, "-", #char "_");
        array_add(*faces, face_name_formatted);

        print_to_builder(*builder, "\tTTF_OpenFont(\"%\", %),\n", path, FONT_DEFAULT_SIZE);
      }
    }
    print_to_builder(*builder, "];");
    array_string := builder_to_string(*builder);

    reset(*builder);
    for faces {
      print_to_builder(*builder, "FONTFACE_% :u16: %;\n", it, it_index);
    }
    enum_string := builder_to_string(*builder);

    add_build_string(enum_string, w = -1);
    return array_string;
  }

  return array_copy(result);
}

Clay_SDL3RendererData :: struct {
  renderer: *SDL_Renderer;
  textEngine: *TTF_TextEngine;
  fonts: **TTF_Font;
}

sdl3_renderer :: #library,no_dll "clay_renderer_sdl3";
SDL_Clay_RenderClayCommands :: (rendererData: *Clay_SDL3RendererData, rcommands: *Clay_RenderCommandArray) #foreign sdl3_renderer;

#import "Basic";
#import "Math";
#import "String";

#import "clay";
#import "sdl3";
#import "sdl3_ttf";
