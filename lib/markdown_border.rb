# frozen_string_literal: true

class MarkdownBorder < TTY::Table::Border
  def_border do
    left         "| "
    center       " | "
    right        " |"
    mid         "-"
    mid_mid     " | "
    mid_left    "| "
    mid_right   " |"
  end
end
