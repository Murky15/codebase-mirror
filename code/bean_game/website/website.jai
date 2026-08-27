COLOR_INK        :: #run color_from_hex(0x2C2C2A);
COLOR_PAPER      :: #run color_from_hex(0xECECEC);
COLOR_CORAL      :: #run color_from_hex(0xFD5C65);
COLOR_AMBER      :: #run color_from_hex(0xFFB600);
COLOR_PERIWINKLE :: #run color_from_hex(0x9279FF);
COLOR_MINT       :: #run color_from_hex(0x36D98C);

SCROLL_Y_SENSITIVITY :: 10.0;

TEXT_CONTAINER_CONFIG :: #run Clay_ElementDeclaration.{
  layout = {sizing = {width = Clay_SizingGrow()}, padding = Clay_PaddingAll(16), childGap = 16, layoutDirection = .TOP_TO_BOTTOM},
  cornerRadius = Clay_CornerRadiusAll(6),
  border = {COLOR_INK, Clay_BorderOutside(4)}
};
BODY_TEXT_CONFIG :: Clay_TextElementConfig.{textColor = COLOR_INK, fontId = FONTFACE_NIPPO_REGULAR, fontSize = 24};

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
  context_pointer := cast(*#Context) error_data.userData;
  push_context context_pointer {
    log_error("%", to_string(error_data.errorText.chars));
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

num_dividers: u32 = 0;
divider :: (width_percent: float, color := COLOR_INK) {
  Clay_UI(Clay_Id("Divider", num_dividers), {layout = {sizing = {width = Clay_SizingGrow()}, childAlignment = {x = .CENTER}}}, #code {
    Clay_UI({layout = {sizing = {Clay_SizingPercent(width_percent), Clay_SizingFixed(5)}}, backgroundColor = color, cornerRadius = Clay_CornerRadiusAll(8)});
  });
  num_dividers += 1;
}

main_title_size: Clay_Dimensions;
header :: () {
  Clay_UI(Clay_Id("Header"), {layout = {sizing = {width = Clay_SizingGrow()}, childGap = 16, childAlignment = {x = .CENTER}, layoutDirection = .TOP_TO_BOTTOM}}, #code {
    small_text_baseline_padding := Clay_Padding.{bottom = 10};
    Clay_UI(Clay_Id("HeaderContent"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, childGap = 16}}, #code {
      main_title_string := "Bean Game";
      main_title_config := Clay_TextElementConfig.{textColor = COLOR_INK, fontId = FONTFACE_TANKER_REGULAR, fontSize = 60, wrapMode = .NONE};
      if main_title_size.width == 0 {
        main_title_size = sdl3_measure_text({length = xx main_title_string.count, chars = main_title_string.data}, *main_title_config, *fonts);
      }
      Clay_UI(Clay_Id("TitleContainer"), {layout = {sizing = {Clay_SizingFit({min = main_title_size.width}), Clay_SizingGrow()}, layoutDirection = .TOP_TO_BOTTOM}}, #code {
        Clay_Text("The", {textColor = COLOR_PERIWINKLE, fontId = FONTFACE_ARRAY_BOLDWIDE, fontSize = 40});
        Clay_Text(main_title_string, main_title_config);
      });
      Clay_UI(Clay_Id("AuthorContainer"), {layout = {sizing = {height = Clay_SizingGrow()}, padding = small_text_baseline_padding, childAlignment = {y = .BOTTOM}}}, #code {
        Clay_Text("By Gianni Bernardi", {textColor = COLOR_INK, fontId = FONTFACE_GEO_REGULAR, fontSize = 32});
      });
      Clay_UI(Clay_Id("SocialsContainer"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, padding = small_text_baseline_padding, childAlignment = {.RIGHT, .BOTTOM}}}, #code {
        Clay_Text("Put socials here", {textColor = COLOR_INK, fontSize = 24});
      });
    });
    divider(1);
  });
}

about :: () {
  Clay_UI(Clay_Id("AboutSectionContainer"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow({min = 100})}, childGap = 16, childAlignment = {y = .CENTER}}}, #code {
    Clay_UI(Clay_Id("AboutTextContainer"), TEXT_CONTAINER_CONFIG, #code {
      Clay_UI(Clay_Id("AboutHeading"), {layout = {sizing = {width = Clay_SizingGrow()}, childAlignment = {.LEFT, .CENTER}}}, #code {
        Clay_Text("About", {textColor = COLOR_PERIWINKLE, fontId = FONTFACE_ARRAY_BOLDWIDE, fontSize = 40});
      });
      divider(0.85);
      Clay_Text(ABOUT_TEXT, BODY_TEXT_CONFIG);
    });
    Clay_UI(Clay_Id("FeatureListContainer"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, padding = Clay_PaddingAll(16), childAlignment = {.RIGHT, .CENTER}}}, #code {
      Clay_UI(Clay_Id("FeatureList"), {layout = { childGap = 32, childAlignment = {x = .CENTER}, layoutDirection = .TOP_TO_BOTTOM}, border = {width = {betweenChildren = 4}, color = COLOR_MINT}}, #code {
        feature_text_config := Clay_TextElementConfig.{textColor = COLOR_INK, fontSize = 36, textAlignment = .CENTER};
        Clay_Text("Custom platformer physics", feature_text_config);
        Clay_Text("Source code available online", feature_text_config);
        Clay_Text("Playable as an app or in your browser", feature_text_config);
        Clay_Text("Create and share your own levels!", feature_text_config);
      });
    });
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

    scroll_amt: Clay_Vector2;

    e: SDL_Event;
    while SDL_PollEvent(*e) {
      if cast(SDL_EventType) e.type == {
        case .SDL_EVENT_QUIT; should_run = false;

        case .SDL_EVENT_WINDOW_RESIZED;
          window_width, window_height = e.window.data1, e.window.data2;
          Clay_SetLayoutDimensions({xx window_width, xx window_height});
        case .SDL_EVENT_MOUSE_WHEEL;
          scroll_amt.x += e.wheel.x;
          scroll_amt.y += e.wheel.y;
      }
    }

    mouse_x, mouse_y: float;
    mouse_buttons := SDL_GetMouseState(*mouse_x, *mouse_y);
    Clay_SetPointerState({mouse_x, mouse_y}, cast(bool, mouse_buttons & 0x1));

    scroll_amt.y *= SCROLL_Y_SENSITIVITY;
    Clay_UpdateScrollContainers(true, scroll_amt, dt);

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
      backgroundColor = COLOR_PAPER}, #code {
      header();

      Clay_UI(Clay_Id("OuterScrollContainer"), {
        layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, padding = Clay_PaddingAll(16), childGap = 32, layoutDirection = .TOP_TO_BOTTOM},
        clip = {vertical = true, childOffset = Clay_GetScrollOffset()}}, #code {
        BODY_DIVIDER_LENGTH_PERCENT :: 0.85;

        Clay_UI(Clay_Id("ButtonContainer"), {layout = {sizing = {width = Clay_SizingGrow()}, childGap = 32, padding = {0, 0, 10, 10}, childAlignment = {x = .CENTER}}}, #code {
          button_decl := Clay_ElementDeclaration.{
            layout = {sizing = {Clay_SizingFixed(140), Clay_SizingFixed(100)}, padding = Clay_PaddingAll(4), childAlignment = {.CENTER, .CENTER}},
            backgroundColor = COLOR_PAPER, // NOTE: Transition to `COLOR_LIGHT_ALT` when hovered
            cornerRadius = Clay_CornerRadiusAll(6),
            border = {COLOR_INK, Clay_BorderOutside(4)}
          };
          button_text_config := Clay_TextElementConfig.{textColor = COLOR_AMBER, fontId = FONTFACE_TANKER_REGULAR, fontSize = 32, textAlignment = .CENTER};

          Clay_UI(Clay_Id("PlayOnlineButton"), button_decl, #code {
            Clay_Text("Play Online", button_text_config);
          });
          Clay_UI(Clay_Id("DownloadNowButton"), button_decl, #code {
            Clay_Text("Download Now", button_text_config);
          });
          Clay_UI(Clay_Id("CustomLevelsButton"), button_decl, #code {
            Clay_Text("Level Library", button_text_config);
          });
        });

        divider(BODY_DIVIDER_LENGTH_PERCENT / 2);
        about();

        divider(BODY_DIVIDER_LENGTH_PERCENT);
        Clay_UI(Clay_Id("CCLContainer"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow({min = 100})}, childGap = 16, layoutDirection = .TOP_TO_BOTTOM}}, #code {
          code_block_config := TEXT_CONTAINER_CONFIG;
          code_block_config.layout.sizing = {};
          code_block_config.backgroundColor = COLOR_INK;

          code_text_config := BODY_TEXT_CONFIG;
          code_text_config.textColor = COLOR_PAPER;

          Clay_UI(Clay_Id("CCLHeader"), {layout = {sizing = {height = Clay_SizingFixed(84)}}}, #code {
            Clay_Text("Creating Custom Levels", {textColor = COLOR_PERIWINKLE, fontId = FONTFACE_ARRAY_BOLDWIDE, fontSize = 40});
          });
          Clay_UI(Clay_Id("CCLSection1"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}, childGap = 24, childAlignment = {.CENTER, .CENTER}}}, #code {
            level_box := Clay_GetElementData(Clay_Id("CCLExampleLevelFile")).boundingBox;
            intro_text_config := TEXT_CONTAINER_CONFIG;
            intro_text_config.layout.sizing = {Clay_SizingFit({300, level_box.width}), Clay_SizingFit({min = level_box.height})};
            Clay_UI(Clay_Id("CCLIntroTextContainer"), intro_text_config, #code {
              Clay_Text(CCL_INTRO_TEXT, BODY_TEXT_CONFIG);
            });
            Clay_UI(Clay_Id("CCLExampleLevelFile"), code_block_config, #code {
              Clay_Text(CCL_EXAMPLE_LEVEL_FILE, code_text_config);
            });
            Clay_UI(Clay_Id("CCLExampleLevelPhoto"), {aspectRatio = {1.0}, image = {}});
          });
          Clay_UI(Clay_Id("CCLSection2"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}}}, #code {
            // Map key list

          });
          Clay_UI(Clay_Id("CCLSection3"), {layout = {sizing = {Clay_SizingGrow(), Clay_SizingGrow()}}}, #code {
            // Metadata tags
          });
        });
      });
    });
  }
}

ABOUT_TEXT :: #string EOF
Hello! My name is Gianni Bernardi. I am a student at the Binghamton University Watson college of Engineering and Applied Science, and I am also a recent graduate of Somers High School.
I have always been infatuated with computers, but I have only seriously gotten into programming since about 2021. I started off writing games for my friends during the COVID-19 lockdowns
while I was in middle school, one of them being the original Bean Game. Now I am a systems programmer, not a webdev, and definitely not a graphic designer either (can you tell?).
I have experience with a variety of languages, but my go-tos are Jai and C. This game is written in Jai. In fact, this website is written in Jai!
My original goal for this game was to bring people together during a challenging time, but I lacked the proper skills to make something I was genuinely proud of. So that's
what this new game is, a gift to my younger self. The game I always wanted but couldn't make. I hope you have as much fun playing it as I did developing it.
EOF

CCL_INTRO_TEXT :: #string EOF
The Bean Game level files were intentionally designed to be easy to create, edit, and share to encourage the development of custom levels. No complicated map editors required!
The underlying file format (.bgdat) houses the level layout in the form of ASCII art as well as some meta tags describing things like
the level name and author. Everything in the file is encoded in plaintext, which means all you need is a standard text editor, like Notepad, to get started making levels.
EOF

TEXT_BLOCKS :: string.[ABOUT_TEXT, CCL_INTRO_TEXT];
#run remove_newlines_from_text_blocks(TEXT_BLOCKS,, temp);

CCL_EXAMPLE_LEVEL_FILE :: #string EOF
Version: 1
Name: Example Level
Author: Gianni Bernardi
Description: Hello, World!
###############################
###############################
###############################
###############################
###############################
###############################
###############################
EOF

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
    print(*builder, "result := *TTF_Font.[\n");
    for dir: FONT_DIRECTORIES_TO_SEARCH {
      if it_index > 0 print(*builder, "\n");

      for path: file_list(dir, recursive = false) {
        extension := path_extension(path);
        if extension != "ttf" && extension != "otf" continue;

        face_name := path_strip_extension(path_filename(path));
        face_name_formatted := to_upper_copy(face_name);
        replace_chars(face_name_formatted, "-", #char "_");
        array_add(*faces, face_name_formatted);

        print(*builder, "\tTTF_OpenFont(\"%\", %),\n", path, FONT_DEFAULT_SIZE);
      }
    }
    print(*builder, "];");
    array_string := builder_to_string(*builder);

    reset(*builder);
    for faces {
      print(*builder, "FONTFACE_% :u16: %;\n", it, it_index);
    }
    enum_string := builder_to_string(*builder);

    add_build_string(enum_string, w = -1);
    return array_string;
  }

  return array_copy(result);
}

Image :: struct {
  width, height: s32;
  data: *u8;
}

init_images :: () -> Table(string, Image) {

}

remove_newlines_from_text_blocks :: (blocks: [] string) {
  for blocks {
    new_string := replace(it, "\n", " ");
    assert(new_string.count == it.count);
    memcpy(it.data, new_string.data, it.count);
  }
}

Clay_SDL3RendererData :: struct {
  renderer: *SDL_Renderer;
  textEngine: *TTF_TextEngine;
  fonts: **TTF_Font;
}

sdl3_renderer :: #library,no_dll "clay_renderer_sdl3";
SDL_Clay_RenderClayCommands :: (rendererData: *Clay_SDL3RendererData, rcommands: *Clay_RenderCommandArray) #foreign sdl3_renderer;

#import "Basic";
#import "Hash_Table";
#import "Math";
#import "String";

#import "clay";
#import "sdl3";
#import "sdl3_ttf";
#import "stb_image";