module ApplicationHelper
  # Closing scripture shown at the foot of each public content page, keyed by
  # "controller_path#action". Each verse (KJV, matching the home page's Psalm
  # 122:1 band) is chosen to echo that page's theme. The home page is omitted —
  # it ends with its own bespoke band. Anything not listed here (CRUD/admin
  # actions, auth pages, errors) shows nothing.
  CLOSING_VERSES = {
    "pages#about" => {
      label: "One Body",
      quote: "Now ye are the body of Christ, and members in particular.",
      reference: "1 Corinthians 12:27"
    },
    "pages#contact" => {
      label: "Reach Out",
      quote: "Ask, and it shall be given you; seek, and ye shall find; knock, and it shall be opened unto you.",
      reference: "Matthew 7:7"
    },
    "pages#accessibility" => {
      label: "All Are Welcome",
      quote: "Come unto me, all ye that labour and are heavy laden, and I will give you rest.",
      reference: "Matthew 11:28"
    },
    "events#index" => {
      label: "Gather Together",
      quote: "For where two or three are gathered together in my name, there am I in the midst of them.",
      reference: "Matthew 18:20"
    },
    "events#show" => {
      label: "Come With Praise",
      quote: "Enter into his gates with thanksgiving, and into his courts with praise: be thankful unto him, and bless his name.",
      reference: "Psalm 100:4"
    },
    "galleries#index" => {
      label: "From Age to Age",
      quote: "One generation shall praise thy works to another, and shall declare thy mighty acts.",
      reference: "Psalm 145:4"
    },
    "galleries#show" => {
      label: "Every Remembrance",
      quote: "I thank my God upon every remembrance of you.",
      reference: "Philippians 1:3"
    },
    "calendar#show" => {
      label: "A Time for Every Season",
      quote: "To every thing there is a season, and a time to every purpose under the heaven.",
      reference: "Ecclesiastes 3:1"
    }
  }.freeze

  def closing_verse
    CLOSING_VERSES["#{controller_path}##{action_name}"]
  end

  # Optimized Cloudinary delivery URL for a raw public_id — assets that are not
  # backed by an Image record (the logo, hand-picked page imagery). Always
  # serves next-gen formats (f_auto), auto quality, and retina DPR. Pass
  # crop:/gravity:/width:/height: for face-aware cropping, mirroring Image's
  # delivery helpers (e.g. crop: :fill, gravity: "auto:faces").
  def cloudinary_image(public_id, **options)
    Cloudinary::Utils.cloudinary_url(
      public_id,
      **{ quality: :auto, fetch_format: :auto, dpr: :auto }.merge(options)
    )
  end

  def ordinalize_day(date)
    date.day.ordinalize
  end

  # "February 5th"
  def month_day_ordinal(date)
    "#{date.strftime('%B')} #{ordinalize_day(date)}"
  end

  # "Wednesday, February 19th"
  def full_date_ordinal(date)
    "#{date.strftime('%A')}, #{month_day_ordinal(date)}"
  end

  # "Wednesday, February 19th, 2026"
  def full_date_ordinal_with_year(date)
    "#{full_date_ordinal(date)}, #{date.year}"
  end

  def format_time(time)
    time&.strftime("%-I:%M %p")
  end

  # "10:00 AM - 11:30 AM" or "10:00 AM"
  def event_time_range(event)
    start = format_time(event.start_time)
    event.end_time.present? ? "#{start} - #{format_time(event.end_time)}" : start
  end

  # ---------------------------------------------------------------------------
  # Ultra-light line icons (Phosphor-Light feel): 1.5 stroke, currentColor.
  # ---------------------------------------------------------------------------
  def line_icon(paths, css: "h-4 w-4")
    tag.svg(paths.html_safe, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
      "stroke-width": "1.5", "stroke-linecap": "round", "stroke-linejoin": "round",
      class: css, "aria-hidden": "true")
  end

  def calendar_icon(css: "h-4 w-4")
    line_icon(%(<rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/><path d="M3.5 9.5h17"/><path d="M8 3.5v3"/><path d="M16 3.5v3"/>), css: css)
  end

  def clock_icon(css: "h-4 w-4")
    line_icon(%(<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>), css: css)
  end

  def pin_icon(css: "h-4 w-4")
    line_icon(%(<path d="M12 21s7-5.5 7-11a7 7 0 1 0-14 0c0 5.5 7 11 7 11z"/><circle cx="12" cy="10" r="2.5"/>), css: css)
  end

  def arrow_up_right_icon(css: "h-4 w-4")
    line_icon(%(<path d="M7 17 17 7"/><path d="M8.5 7H17v8.5"/>), css: css)
  end

  def chevron_left_icon(css: "h-4 w-4")
    line_icon(%(<path d="M14.5 6 9 12l5.5 6"/>), css: css)
  end

  def chevron_right_icon(css: "h-4 w-4")
    line_icon(%(<path d="M9.5 6 15 12l-5.5 6"/>), css: css)
  end
end
