class MakeHealingBallGraphics

  def initialize
    balls=[]
    for poke in $player.party
      balls.push(poke.poke_ball) if !poke.egg? #balls.push(poke.ballused) if !poke.isEgg?
    end
    return false if balls.length==0
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=999999
    for i in 0...balls.length
      @sprites["ball#{i}"]=Sprite.new(@viewport)
      if pbResolveBitmap("Graphics/Pictures/Balls/ball_#{balls[i]}.png")
        @sprites["ball#{i}"].bitmap=Bitmap.new("Graphics/Pictures/Balls/ball_#{balls[i]}.png")
      else
        @sprites["ball#{i}"].bitmap=Bitmap.new("Graphics/Pictures/Balls/ball_0.png")
      end
      @sprites["ball#{i}"].visible=false
    end
    bitmap1=Bitmap.new(256,192)
    bitmap2=Bitmap.new(256,192)
    rect1=Rect.new(0,0,256,192/4)
    for i in 0...balls.length
      case i
      when 0
        bitmap1.blt(36,50,@sprites["ball#{0}"].bitmap,rect1)
      when 1
        bitmap2.blt(36,50,@sprites["ball#{0}"].bitmap,rect1)
        bitmap2.blt(48,50,@sprites["ball#{1}"].bitmap,rect1)
      when 2
        bitmap1.blt(36,98,@sprites["ball#{0}"].bitmap,rect1)
        bitmap1.blt(48,98,@sprites["ball#{1}"].bitmap,rect1)
        bitmap1.blt(36,106,@sprites["ball#{2}"].bitmap,rect1)
      when 3
		bitmap2.blt(36,98,@sprites["ball#{0}"].bitmap,rect1)
        bitmap2.blt(48,98,@sprites["ball#{1}"].bitmap,rect1)
        bitmap2.blt(36,106,@sprites["ball#{2}"].bitmap,rect1)
        bitmap2.blt(48,106,@sprites["ball#{3}"].bitmap,rect1)
      when 4
		bitmap1.blt(36,146,@sprites["ball#{0}"].bitmap,rect1)
		bitmap1.blt(48,146,@sprites["ball#{1}"].bitmap,rect1)
		bitmap1.blt(36,154,@sprites["ball#{2}"].bitmap,rect1)
		bitmap1.blt(48,154,@sprites["ball#{3}"].bitmap,rect1)
		bitmap1.blt(36,162,@sprites["ball#{4}"].bitmap,rect1)
      when 5
		bitmap2.blt(36,146,@sprites["ball#{0}"].bitmap,rect1)
		bitmap2.blt(48,146,@sprites["ball#{1}"].bitmap,rect1)
		bitmap2.blt(36,154,@sprites["ball#{2}"].bitmap,rect1)
		bitmap2.blt(48,154,@sprites["ball#{3}"].bitmap,rect1)
        bitmap2.blt(36,162,@sprites["ball#{4}"].bitmap,rect1)
        bitmap2.blt(48,162,@sprites["ball#{5}"].bitmap,rect1)
      end
      Graphics.update
    end
    if RTP.exists?("Graphics/Characters/Healing balls 1.png")
      File.delete("Graphics/Characters/Healing balls 1.png")
    end
    if RTP.exists?("Graphics/Characters/Healing balls 2")
      File.delete("Graphics/Characters/Healing balls 2")
    end
    bitmap1.to_file("Graphics/Characters/Healing balls 1.png")
    bitmap2.to_file("Graphics/Characters/Healing balls 2.png")
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    bitmap1.dispose
    bitmap2.dispose
  end
end

class MakeHealingMonitorGraphics
  CELL_WIDTH  = 128#64
  CELL_HEIGHT = 96#48
  ICON_OFFSET_X = 18#0    # Adjust to move icon left/right within its cell
  ICON_OFFSET_Y = 15#-12  # Adjust to move icon up/down within its cell (negative = up)
  ICON_SCALE   = 0.35      # Multiply final icon size by this factor
  ICON_ROW_OFFSET_X = 20#18   # Offset for row sheet icons (left/right)
  ICON_ROW_OFFSET_Y = 15#-20  # Offset for row sheet icons (up/down)
  ICON_ROW_SCALE    = 0.45#0.75 # Scale for row sheet icons
  ICON_ROW_ICON1_OFFSET_X = 8#-6 # Additional offset for first icon in a pair
  ICON_ROW_ICON2_OFFSET_X = -15#6  # Additional offset for second icon in a pair
  OUTPUTS = [
    "Graphics/Characters/Healing monitor 1.png",
    "Graphics/Characters/Healing monitor 2.png"
  ].freeze
  LOCKED_OUTPUTS = {
    0 => "Graphics/Characters/Healing monitor slot1.png",
    1 => "Graphics/Characters/Healing monitor slot2.png",
    2 => "Graphics/Characters/Healing monitor slot3.png",
    3 => "Graphics/Characters/Healing monitor slot4.png",
    4 => "Graphics/Characters/Healing monitor slot5.png",
    5 => "Graphics/Characters/Healing monitor slot6.png"
  }.freeze
  ROW_OUTPUT = "Graphics/Characters/Healing monitor row.png"
  # Mapping: party slot => [sheet index, row index]
  SLOT_MAP = [
    [0, 1], # slot 1 -> sheet 1, row 2
    [1, 1], # slot 2 -> sheet 2, row 2
    [0, 2], # slot 3 -> sheet 1, row 3
    [1, 2], # slot 4 -> sheet 2, row 3
    [0, 3], # slot 5 -> sheet 1, row 4
    [1, 3]  # slot 6 -> sheet 2, row 4
  ].freeze

  def initialize
    icons = Array.new(SLOT_MAP.length)
    SLOT_MAP.each_index do |idx|
      pkmn = $player.party[idx]
      next if !pkmn || pkmn.egg?
      icons[idx] = GameData::Species.icon_bitmap_from_pokemon(pkmn) || Bitmap.new(CELL_WIDTH, CELL_HEIGHT)
    end
    return false if icons.compact.empty?
    sheets = OUTPUTS.map { Bitmap.new(CELL_WIDTH * 4, CELL_HEIGHT * 4) }
    row_sheet = Bitmap.new(CELL_WIDTH * 4, CELL_HEIGHT * 4)
    locked_sheets = {}
    LOCKED_OUTPUTS.each do |slot_idx, path|
      next unless icons[slot_idx]
      locked_sheets[slot_idx] = [path, Bitmap.new(CELL_WIDTH * 4, CELL_HEIGHT * 4)]
    end
    icons.each_with_index do |icon, idx|
      sheet_idx, row_idx = SLOT_MAP[idx]
      draw_icon_on_sheet(sheets[sheet_idx], icon, row_idx)
    end
    draw_row_sheet(row_sheet, icons)
    locked_sheets.each do |slot_idx, (_path, bmp)|
      draw_locked_sheet(bmp, icons[slot_idx])
    end
    OUTPUTS.each_with_index do |path, idx|
      File.delete(path) if RTP.exists?(path)
      sheets[idx].to_file(path)
    end
    File.delete(ROW_OUTPUT) if RTP.exists?(ROW_OUTPUT)
    row_sheet.to_file(ROW_OUTPUT)
    locked_sheets.each_value do |path, bmp|
      File.delete(path) if RTP.exists?(path)
      bmp.to_file(path)
    end
  ensure
    icons.each(&:dispose) if icons
    sheets.each(&:dispose) if sheets
    row_sheet.dispose if row_sheet
    locked_sheets.each_value { |_, bmp| bmp.dispose } if defined?(locked_sheets)
  end

  private

  def icon_frame(icon)
    frame_width = icon.width
    frame_height = icon.height
    if icon.width.even? && icon.width > icon.height
      frame_width = icon.width / 2
    end
    return frame_width, frame_height, Rect.new(0, 0, frame_width, frame_height)
  end

  def draw_icon_on_sheet(sheet, icon, row_idx)
    return if row_idx.nil? || icon.nil?
    # Use only column 1 (frame 0), leave other columns blank.
    dest_x = 0
    dest_y = row_idx * CELL_HEIGHT
    frame_width, frame_height, src_rect = icon_frame(icon)
    scale = [CELL_WIDTH.to_f / frame_width, CELL_HEIGHT.to_f / frame_height].min * ICON_SCALE
    target_w = [(frame_width * scale).floor, 1].max
    target_h = [(frame_height * scale).floor, 1].max
    offset_x = dest_x + ((CELL_WIDTH - target_w) / 2) + ICON_OFFSET_X
    offset_y = dest_y + ((CELL_HEIGHT - target_h) / 2) + ICON_OFFSET_Y
    offset_x = [[offset_x, dest_x].max, dest_x + CELL_WIDTH - target_w].min
    offset_y = [[offset_y, dest_y].max, dest_y + CELL_HEIGHT - target_h].min
    dest_rect = Rect.new(offset_x, offset_y, target_w, target_h)
    sheet.stretch_blt(dest_rect, icon, src_rect)
  end

  def draw_row_sheet(sheet, icons)
    pairs = [[0, 1], [2, 3], [4, 5]]
    pairs.each_with_index do |(a, b), idx|
      col_index = idx + 1 # column 1 is blank
      draw_row_cell(sheet, icons[a], icons[b], col_index)
    end
  end

  def draw_row_cell(sheet, icon_a, icon_b, col_index)
    return if icon_a.nil? && icon_b.nil?
    cell_x = col_index * CELL_WIDTH
    cell_y = CELL_HEIGHT # use row 2; rows 1,3,4 remain blank
    centers = [
      cell_x + (CELL_WIDTH * 0.33) + ICON_ROW_ICON1_OFFSET_X,
      cell_x + (CELL_WIDTH * 0.67) + ICON_ROW_ICON2_OFFSET_X
    ]
    [icon_a, icon_b].each_with_index do |icon, i|
      next unless icon
      frame_width, frame_height, src_rect = icon_frame(icon)
      max_w = CELL_WIDTH / 2.0
      max_h = CELL_HEIGHT.to_f
      scale = [max_w / frame_width, max_h / frame_height].min * ICON_ROW_SCALE
      target_w = [(frame_width * scale).floor, 1].max
      target_h = [(frame_height * scale).floor, 1].max
      center_x = centers[i]
      offset_x = center_x - (target_w / 2) + ICON_ROW_OFFSET_X
      offset_y = cell_y + ((CELL_HEIGHT - target_h) / 2) + ICON_ROW_OFFSET_Y
      # Clamp within the cell to avoid cutting off edges
      offset_x = [[offset_x, cell_x].max, cell_x + CELL_WIDTH - target_w].min
      offset_y = [[offset_y, cell_y].max, cell_y + CELL_HEIGHT - target_h].min
      dest_rect = Rect.new(offset_x, offset_y, target_w, target_h)
      sheet.stretch_blt(dest_rect, icon, src_rect)
    end
  end

  def draw_locked_sheet(sheet, icon)
    return unless icon
    4.times do |row|
      draw_icon_on_sheet(sheet, icon, row)
    end
  end
end
