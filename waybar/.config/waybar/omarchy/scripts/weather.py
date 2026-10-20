#!/usr/bin/env python3
import json
import os
import sys
import time
import urllib.request
from datetime import datetime

CACHE_FILE = "/tmp/omarchy_waybar_weather_cache.json"
CACHE_TTL = 600  # 10 minutes cache

ICON_MAP_DAY = {
    113: "",  # Sunny
    116: "",  # PartlyCloudy
    119: "",  # Cloudy
    122: "",  # VeryCloudy
    143: "",  # Fog
    176: "",  # LightShowers
    179: "",  # LightSnowShowers
    182: "",  # LightSleetShowers
    185: "",  # LightSleet
    200: "",  # ThunderyShowers
    227: "",  # LightSnow
    230: "",  # HeavySnow
    248: "",  # Fog
    260: "",  # Fog
    263: "",  # LightRain
    266: "",  # LightRain
    281: "",  # LightSleet
    284: "",  # LightSleet
    293: "",  # LightRain
    296: "",  # LightRain
    299: "",  # HeavyShowers
    302: "",  # HeavyRain
    305: "",  # HeavyShowers
    308: "",  # HeavyRain
    311: "",  # LightSleet
    314: "",  # LightSleet
    317: "",  # LightSleet
    320: "",  # LightSnow
    323: "",  # LightSnowShowers
    326: "",  # LightSnowShowers
    329: "",  # HeavySnow
    332: "",  # HeavySnow
    335: "",  # HeavySnowShowers
    338: "",  # HeavySnow
    350: "",  # LightSleet
    353: "",  # LightShowers
    356: "",  # HeavyShowers
    359: "",  # HeavyRain
    362: "",  # LightSleetShowers
    365: "",  # LightSleetShowers
    368: "",  # LightSnowShowers
    371: "",  # HeavySnowShowers
    374: "",  # LightSleetShowers
    377: "",  # LightSleet
    386: "",  # ThunderyShowers
    389: "",  # ThunderyHeavyRain
    392: "",  # ThunderySnowShowers
    395: "",  # ThunderySnowShowers
}

ICON_MAP_NIGHT = {
    113: "",  # Clear
    116: "",  # PartlyCloudy
    119: "",  # Cloudy
    122: "",  # VeryCloudy
    143: "",  # Fog
    176: "",  # LightShowers
    179: "",  # LightSnowShowers
    182: "",  # LightSleetShowers
    185: "",  # LightSleet
    200: "",  # ThunderyShowers
    227: "",  # LightSnow
    230: "",  # HeavySnow
    248: "",  # Fog
    260: "",  # Fog
    263: "",  # LightRain
    266: "",  # LightRain
    281: "",  # LightSleet
    284: "",  # LightSleet
    293: "",  # LightRain
    296: "",  # LightRain
    299: "",  # HeavyShowers
    302: "",  # HeavyRain
    305: "",  # HeavyShowers
    308: "",  # HeavyRain
    311: "",  # LightSleet
    314: "",  # LightSleet
    317: "",  # LightSleet
    320: "",  # LightSnow
    323: "",  # LightSnowShowers
    326: "",  # LightSnowShowers
    329: "",  # HeavySnow
    332: "",  # HeavySnow
    335: "",  # HeavySnowShowers
    338: "",  # HeavySnow
    350: "",  # LightSleet
    353: "",  # LightShowers
    356: "",  # HeavyShowers
    359: "",  # HeavyRain
    362: "",  # LightSleetShowers
    365: "",  # LightSleetShowers
    368: "",  # LightSnowShowers
    371: "",  # HeavySnowShowers
    374: "",  # LightSleetShowers
    377: "",  # LightSleet
    386: "",  # ThunderyShowers
    389: "",  # ThunderyHeavyRain
    392: "",  # ThunderySnowShowers
    395: "",  # ThunderySnowShowers
}


def fetch_weather_data():
    now = time.time()
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                cached = json.load(f)
                if now - cached.get("timestamp", 0) < CACHE_TTL:
                    return cached.get("data")
        except Exception:
            pass

    try:
        req = urllib.request.Request(
            "https://wttr.in?format=j1",
            headers={"User-Agent": "curl/8.0"}
        )
        with urllib.request.urlopen(req, timeout=4) as response:
            data = json.loads(response.read().decode("utf-8"))
            with open(CACHE_FILE, "w") as f:
                json.dump({"timestamp": now, "data": data}, f)
            return data
    except Exception:
        # If fetch fails, try stale cache if available
        if os.path.exists(CACHE_FILE):
            try:
                with open(CACHE_FILE, "r") as f:
                    return json.load(f).get("data")
            except Exception:
                pass
        return None


def parse_weather(data):
    if not data:
        return None

    try:
        cur = data["current_condition"][0]
        code = int(cur["weatherCode"])
        temp = cur["temp_C"]
        desc = cur["weatherDesc"][0]["value"]
        wind = f"{cur['windspeedKmph']}km/h"

        area = "Weather"
        try:
            area = data["nearest_area"][0]["areaName"][0]["value"]
        except Exception:
            pass

        # Day / night calculation based on sunrise & sunset
        is_night = False
        try:
            astro = data["weather"][0]["astronomy"][0]
            sr_str = astro["sunrise"].strip()
            ss_str = astro["sunset"].strip()
            now_dt = datetime.now()
            today_str = now_dt.strftime("%Y-%m-%d")
            sr_dt = datetime.strptime(f"{today_str} {sr_str}", "%Y-%m-%d %I:%M %p")
            ss_dt = datetime.strptime(f"{today_str} {ss_str}", "%Y-%m-%d %I:%M %p")
            is_night = (now_dt < sr_dt or now_dt >= ss_dt)
        except Exception:
            # Fallback to local hour (night if before 6am or after 6pm)
            hour = datetime.now().hour
            is_night = (hour < 6 or hour >= 18)

        icon_map = ICON_MAP_NIGHT if is_night else ICON_MAP_DAY
        icon = icon_map.get(code, "")

        return {
            "icon": icon,
            "temp": temp,
            "desc": desc,
            "wind": wind,
            "area": area,
        }
    except Exception:
        return None


def main():
    notify_mode = "--notify" in sys.argv or "-n" in sys.argv
    data = fetch_weather_data()
    weather = parse_weather(data)

    if not weather:
        if notify_mode:
            os.system('notify-send -u low "Weather" "Weather data unavailable"')
        else:
            print(json.dumps({"text": "", "class": "unavailable"}))
        return

    icon = weather["icon"]
    area = weather["area"]
    temp = weather["temp"]
    wind = weather["wind"]
    desc = weather["desc"]

    if notify_mode:
        msg = f"{icon}    {area}  ·  Temp {temp}°C  ·  Wind {wind}  ·  {desc}"
        os.system(f'notify-send -u low "Omarchy Weather" "{msg}"')
    else:
        tooltip = f"{icon}  {area} · {desc}\nTemp: {temp}°C\nWind: {wind}"
        print(json.dumps({"text": icon, "tooltip": tooltip}))


if __name__ == "__main__":
    main()
