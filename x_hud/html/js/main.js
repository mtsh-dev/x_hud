const Root = document.querySelector(":root");
let stats = {};

var LockHud = true

let HudEnabled = true,
  CarHudEnabled = true,
  carhudActive = false,
  cinema = false,
  watermarkOn = false;
const Settings = document.getElementById("settings");
const Time = document.getElementById("timeValue");
const Hud = document.getElementById("hud_display");
const CarHud = document.getElementById("carhud");
const Speedometer = document.getElementById("speedometer_value");
const Location = document.getElementById("location");
const Direction = document.getElementById("direction");

if (localStorage.getItem("primaryColor") == null) {
  localStorage.setItem("primaryColor", "#25d8db");
  $('#change_primary').val('#25d8db');
} else {
  var color = localStorage.getItem("primaryColor");
  Root.style.setProperty("--primaryColor", color);
  $('#change_primary').val(color);
}
if (localStorage.getItem("secondaryColor") == null) {
  localStorage.setItem("secondaryColor", "#1A1919");
  $('#change_secondary').val('#1A1919');
} else {
  var color = localStorage.getItem("secondaryColor");
  Root.style.setProperty("--secondaryColor", color);
  $('#change_secondary').val(color);
}

const ToggleHud = function (element, value) {
  if (value) {
    element.style.display = "block";
    if (element.classList.contains("right-slide-in"))
      element.classList.remove("right-slide-in");
    element.classList.add("right-slide-out");
  } else {
    if (element.classList.contains("right-slide-out"))
      element.classList.remove("right-slide-out");
    element.classList.add("right-slide-in");
    setTimeout(() => {
      element.style.display = "none";
    }, 200);
  }
};

const Post = async function (name, data) {
  try {
    let resp = await fetch(`https://${GetParentResourceName()}/${name}`, {
      method: "POST",
      mode: "same-origin",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify(data || {}),
    });
    if (!resp.ok) {
      return;
    }
    return await resp.json();
  } catch (err) {}
};

var ColorChabge = false
const UpdateColor = function (primary, color) {
  ColorChabge = true
  if (primary) {
    localStorage.setItem("primaryColor", color);
  } else {
    localStorage.setItem("secondaryColor", color);
  }

  Root.style.setProperty(
    primary ? "--primaryColor" : "--secondaryColor",
    color
  );

  
};

const SetIconPercent = function (target, value, istalking) {

  if (target == 'voice' && istalking == true) {
    $("#" + target).css("background-image", "linear-gradient(0deg, #fff 0%, #fff "+value+"%, rgba(0, 0, 0, 0) "+value+"%, rgba(0, 0, 0, 0) 100%)");
  } else {
    $("#" + target).css("background-image", "linear-gradient(0deg, var(--primaryColor) 0%, var(--primaryColor) "+value+"%, rgba(0, 0, 0, 0) "+value+"%, rgba(0, 0, 0, 0) 100%)");
  }
};

const ToggleStat = function (target) {
  if (target.id == "unit") {
  } else {
    let enabled = true;
    if (target.textContent == "ON") {
      target.textContent = "OFF";
      target.style.borderColor = "rgb(247, 43, 43)";
      enabled = false;
    } else {
      target.textContent = "ON";
      target.style.borderColor = "rgb(43, 247, 145)";
    }
    switch (target.id) {
      case "show_hud":
        HudEnabled = enabled;
        Post("toggle", {
          value: enabled,
        }).then(() => {
          ToggleHud(Hud, HudEnabled);
        });
        break;
      case "show_carhud":
        CarHudEnabled = enabled;
        Post("toggle", {
          value: enabled,
          carhud: true,
        }).then(() => {
          if (carhudActive) {
            ToggleHud(CarHud, CarHudEnabled);
          }
        });
        break;
      case "cinema":
        cinema = !cinema;
        document.getElementById("hud_container").style.display = cinema
          ? "none"
          : "block";
        let element = document.getElementById("cinema_container");
        if (cinema) {
          if (element.classList.contains("close-down"))
            element.classList.remove("close-down");
          element.classList.add("show-up");
        } else {
          if (element.classList.contains("show-up"))
            element.classList.remove("show-up");
          element.classList.add("close-down");
        }
        break;
      case "watermark_display":
        watermarkOn = !watermarkOn;
        let watermark = document.getElementById("watermark");
        if (!cinema) {
          if (watermarkOn) {
            watermark.classList.remove("watermark-in");
            watermark.classList.add("watermark-out");
          } else {
            watermark.classList.remove("watermark-out");
            watermark.classList.add("watermark-in");
          }
        }
        break;
      default:
        break;
    }
  }
};
const Initalize = function () {
  const defaultSettings = [
    {
      id: "show_hud",
      style: {
        borderColor: "rgb(43, 247, 145)",
      },
      textContent: "ON",
    },
    {
      id: "show_carhud",
      style: {
        borderColor: "rgb(43, 247, 145)",
      },
      textContent: "ON",
    },
    {
      id: "scroll",
      style: {
        borderColor: "rgb(43, 247, 145)",
      },
      textContent: "ON",
    },
    {
      id: "cinema",
      style: {
        borderColor: "rgb(247, 43, 43)",
      },
      textContent: "OFF",
    },
    {
      id: "watermark_display",
      style: {
        borderColor: "rgb(43, 247, 145)",
      },
      textContent: "ON",
    },
  ];
  for (let i = 0; i < defaultSettings.length; i++) {
    const s = defaultSettings[i];
    let element = document.getElementById(s.id);
    if (element) {
      if (s.textContent) element.textContent = s.textContent;
      if (s.style)
        for (const k in s.style)
          if (Object.hasOwnProperty.call(s.style, k))
            element.style[k] = s.style[k];
    }
  }
};

document
  .getElementById("change_primary")
  .addEventListener("input", function () {
    UpdateColor(true, this.value);
  });

document
  .getElementById("change_secondary")
  .addEventListener("input", function () {
    UpdateColor(false, this.value + "f9");
  });

let visible = false;
const Watermark = document.getElementById("id-background");
const AllWatermark = document.getElementById("watermark");


window.addEventListener("message", function (event) {
  let e = event.data;
  switch (e.action) {
    case "settings":
      Settings.style.display = e.show ? "block" : "none";

      if (e.show == false && ColorChabge == true) {
        $.post(`https://${GetParentResourceName()}/updateColor`, JSON.stringify({
          primaryColor : Root.style.getPropertyValue('--primaryColor'),
          secondaryColor : Root.style.getPropertyValue('--secondaryColor'),
        }))
      }
      ColorChabge = false
      break;
    case "update_hud":
      for (const key in e.hudIcons || {}) {
        SetIconPercent(key, e.hudIcons[key], e.voice);
      }
      break;
    case "hudChangeId":
      $("#main-id").html(e.playerid)
      break;
    case "pauseMenu":
      if (e.data) {
        ToggleHud(AllWatermark, false);
        ToggleHud(CarHud, false);
        ToggleHud(Hud, false);
      } else {
        if (carhudActive && LockHud == true) {
          ToggleHud(CarHud, true);
        }
        if (LockHud == true) {
          ToggleHud(AllWatermark, true);
          ToggleHud(Hud, true);
        }
      }
      break;
    case "carhud":
      carhudActive = e.show;
      if (LockHud == true) {
        ToggleHud(CarHud, e.show);
      }
      
      break;
    case "playerLoad":
      $("body").fadeIn();
      $("#hud_container").fadeIn();
      $("#watermark").fadeIn();
      $.post(`https://${GetParentResourceName()}/updateColor`, JSON.stringify({
        primaryColor : Root.style.getPropertyValue('--primaryColor'),
        secondaryColor : Root.style.getPropertyValue('--secondaryColor'),
      }))
      break;
    case "toggleHud":
        LockHud = !LockHud;
        if (LockHud) {
          if (carhudActive && LockHud == true) {
            ToggleHud(CarHud, true);
          }
          ToggleHud(Hud, true);
          ToggleHud(AllWatermark, true);
        } else {
          if (carhudActive) {
            ToggleHud(CarHud, false);
          }
          ToggleHud(Hud, false);
          ToggleHud(AllWatermark, false);
        }
      break;
    case 'switchhud':
      if (e.switchHud) {
        $('body').fadeIn();
      } else {
        $('body').fadeOut();
      }
      break;
    case "update_carhud":
      Speedometer.textContent = e.speed;
      Location.textContent = e.location;
      Direction.textContent = e.direction;
      break;
    case "WatermarkShow":
      visible = e.show;
      if (visible) {
        if (Watermark.classList.contains("watermark-out"))
          Watermark.classList.remove("watermark-out");
        Watermark.classList.add("watermark-in");
      } else {
        if (Watermark.classList.contains("watermark-in"))
          Watermark.classList.remove("watermark-in");
        Watermark.classList.add("watermark-out");
      }
      break;

    default:
      break;
  }
});

window.addEventListener("keydown", function (e) {
  if (e.key == "Escape") Post("close");
});

Initalize();