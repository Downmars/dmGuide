
# Waybar basic guide.

Waybar is a highly customizable status bar. Next, i will give you on how to use it.  

[Waybar Wike](https://github.com/Alexays/Waybar/wiki)

---

# Configuration

## Config file
The configuration uses the JSONC file format and is named `config` or `config.jsonc`, it mostly in `~/.config/waybar/`.  

### Bar Config  
| option | typeof | default| description |
|:---:|:---:|:---:|---|
| `layer` | string | bottom | Decide if the bar is displayed in front (`top`) of the windows or behind (`bottom`) them. |
| `output` |string | array | / |
| `position` | string | top | Bar position, can be `top`, `bottom`, `left`, `right`. |
| `width` | integer | / | Width to be used by the if possible, leave blank for a dynamic value. |
| `modules-left` | array | / | Modules that will be displayed on the left. |
| `modules-center` | array | / | Modules that will be displayed on the center. |
| `modules-right` | array | / | Modules that will be displayed on the right. |
| `margin` | string | / | Margin value using the css format without units. |
| `margin-<top|left|bottom|right>` | integer | / | Margin value without units. |
| `spacing` | integer | 4 | Size of gaps in between of the different modules. |
| `name` | string | / | Optional name added as a CSS class, for styling multiple waybars. |
| `mode` | string | / | Select one of the preconfigured display modes. This is an equivalent of the `sway-bar(5)` mode command and supports the same values:`dock`, `hide`, `invisible`, `overlay`.   Note: `hide` and `invisible` modes may be not as useful without Sway IPC. |
| `start_hidden` | bool | false | Option to start the bar hidden. |
| `modifier-reset` | string | press | Defines the timing of modifier key to reset the bar visibility. To reset the visibility of the bar with the press of the modifier key use `press`. Using `release` to reset the visibility upon the release of the modifier key and only if no other action happened while the key was passed. This prevents hiding the bar when the modifier is used to switch a workspace, change binding mode or start a keybind. |
| `exclusive` | bool | ture | Option to request an exclusive zone from the compositor. Disable this to allow drawing appalication windows underneath or on top of the bar. Disabled by default for `overlay` layer. |
| `fixed-center` | bool | true | Prefer fixed cneter position for the `modules-center` block. The conter block will stay middle of the bar whenever possible. It can still be pushed around if other blocks need more space. When false, the center block is cnetered in the space between the left and right block. |
| `passthrough` | bool | false | Option to pass any pointer events to the window under the bar. Intended to be used with either `top` or `overlay` layers and without exclusive zone. Enable by default for `overlay` layer. |
| `ipc` | bool | false | Option to subscribe to the Sway IPC bar configuration and visibility events and control waybar with `swaymsg bar` commands. Requires `bar_id` value from sway configuration to be either passed with `-b` commandline argument or specified with the `id` option. See [#1244](https://github.com/Alexays/Waybar/pull/1244) for the documentation and configuration examples. |
| `id` | string | / | `bar_id` for the Sway IPC. Using this if you need to override the value passed with the `-b bar_id` commandline argument for the specific bar instance. |
| `include` | array | / | Paths to additional configuration files.  Each file can contain a single object with any of the bar configuration options. In case of duplicate options, the first defined value takes precedence, i.e. including file -> first include file -> etc. Nested includes are permitted, but make sure to avoid circular imports. For a multi-bar config, the `include` directive affects only current bar configuration object. |
| `reload_style_on_change` | bool | false | Option to enable reloading the css style if a modification is detected on the style sheet file or any imported css files. |

### Modules Config 
It's suggested to not have multiple configurations for the same mouse button. For example: `on-click`, `on-double-click`, `on-triple-click` are defined. When triple click is triggered the module will execute commands for `on-click`, `on-double-click`, `on-triple-click` sequentially because of Gdk provide such events.  

| option | typeof | default | description |
|:---:|:---:|:---:|---|
| `on-click` | string | / | Command to execute when you left click on the module. |
| `on-click-release` | string | / | Command to execute when you release left button on the module. |
| `on-double-click` | string | / | Command to execute when you double left click on the module. |
| `on-triple-click` | string | / | Command to execute when you triple left click on the module. |
| `on-click-middle` | string | / | Command to execute when you middle click on the module using mouse-wheel. |
| `on-click-middle-release` | string | / | Command to execute when you release mouse-wheel button on the module. |
| `on-double-click-middle` | string | / | Command to execute when you double middle click on the module using mouse-wheel. |
| `on-triple-click-middle` | string | / | Command to execute when you triple middle click on the module using mouse-wheel. |
| `on-click-right` | string | / | Command to execute when you right click on the module. |
| `on-click-right-release` | string | / | Command to execute when you release right button on the module. |
| `on-double-click-right` | string | / | Command to execute when you double right click on the module. |
| `on-triple-click-right` | string | / | Command to execute when you triple right click on the module. |
| `on-{, double-, triple-}click-{backward-, forward-}` | string | / | Command to execute when you {, double, triple} click on the module using mouse {backward, forward} button. |
| `on-click-{backward-, forward-}-release` | string | / | Command to execute when you release mouse {backward, forward} button on the module. |
| `on-scroll-{up, down}` | string | / | Command to execute when you scroll {up, down} on the module with the mouse-wheel. |
| `on-scroll-{left, right}` | string | / | Command to execute when you tiltthe mouse-wheel {left, right} on the module. |

## How to deal with Waybar?

Befor start talking about modules and how to configure them, we want to write the "general" Waybar configuration. Here is an example:
```
{
  "layer": "bottom",
  "position": "top",
  "height": 24,
  "spacing": 5, 
  "modules-left": ["sway/workspace", "sway/mode"],
  "modules-cneter": ["sway/window"],
  "modules-right": ["battery", "clock"]
}
```
The guide you want to know is how to make a custom module, i will give some suggestions. Other default module you can see in [Wiki](https://github.com/Alexays/Waybar/wiki).
## Module: Custom 

Addressed by `custom/<name>`  

| option | typeof | default | description |  
|:---:|:---:|:---:|---|  
| exec | string | / | / |
| `exec-if` | string | / | The path to a script, which determines if the script in `exec` should be executed. `exec` will be executed if the exit code of `exec-if` equals 0. |
| `exec-on-event` | bool | true | If an event command is set (e.g. `on-click` or `on-scroll-up`) then reexecute the script.<br> There are no guarantees that `exec` is executed after the `on-*` event commands finished. See [https://github.com/Alexays/Waybar/pull/1784](https://github.com/Alexays/Waybar/pull/1784) for a possible patch. |  
| `hide-empty-text` | bool | false | (version >= 0.10.3) Disable the module when the output is empty, but format might contain additional static content. |  
| `return-type` | string | / | See in [return-type](https://github.com/Alexays/Waybar/wiki/Module:-Custom#module-custom-config-return-type) |  
| `interval` | integer | / | The interval (s) in which the information gets polled.<br> Use `once` if you want to execute the module only on startup. You can update it manually with a signal. If on `interval` is defined, it is assumed that the output script loops it self. |  
| `restart-interval` | integer | / | The restart interval (s). Can't be used with the `interval` option, so only with continuous scripts. Once the script exit, it'll be re-executed after the `restart-interval`. |
| `signal` | integer | / | The signal number used to update the module. The number is vaild between 1 and N, where `SIGRTMIN + N` = `SIGRTMAX`. |
| `format` | string | {} | The format, how information should be displayed. On `{}` date gets inserted. |
| `format-icons` | array/odject/string | / | If the type is an array, then based on the set percentage, the corresponding icon gets selected (low -> high). <br> If the type is an object, then the icon will be selected according to `alt` string from the output. <br> If the type is a string, it will be pasted as is. <br> **NOTE**:Arrays can be nested into objects. Icons will be selected first according to `alt` the percentage. |
| `rotate` | integer | / | Positive value to rotate the lable. |
| `max-length` | integer | / | The maximum length in character the module should display. |
| `on-click` | string | / | Command to execute when clicked on the module. |
| `on-click-{middle, right}` | string | / | Command to execute when you {middle clicked, right clicked} on the module. |
| `on-scroll-{up, down}` | string | / | Command to execute when scrolling {up, down} on the module. |
| `smooth-scrolling-threshold` | double | / | Threshold to be used when scrolling. |
| `tooltip` | bool | true | Option to enable tooltip on hover. |
| `tooltip-format` | string | / | The format of the tooltip. |
| `escape` | bool | false | Option to enable escaping of script output. |

#### Return-Type: 
When `return-type` is set to `json`, Waybar expects the `exec-script` to output its data in JSON format. This should look like this :`{"text": "$text", "alt": "$alt", "tooltip": "$tooltip", "class": "$class", "percentage": "$percentage" }`. 
