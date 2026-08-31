main :: () {
  window := create_window(1280, 720, "Galaxie");

  should_run := true;
  while should_run {
    reset_temporary_storage();
    Input.update_window_events();

    for Input.events_this_frame {
      if it.type == .QUIT then should_run = false;
    }
  }
}

#import "Basic";

#import "Window_Creation";
Input :: #import "Input";
Simp  :: #import "Simp";