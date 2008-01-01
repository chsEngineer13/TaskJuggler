#
# ReportTableCell.rb - The TaskJuggler III Project Management Software
#
# Copyright (c) 2006, 2007, 2008 by Chris Schlaeger <cs@kde.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#

# This class models the output format independent version of a cell in a
# ReportTableElement. It belongs to a certain ReportTableLine and
# ReportTableColumn. Normally a cell contains text on a colored background.
# By help of the @special variable it can alternatively contain any object the
# provides the necessary output methods such as to_html.
class ReportTableCell

  attr_reader :line
  attr_accessor :data, :text, :category, :hidden, :alignment, :padding, :indent,
                :fontSize, :bold, :width, :rows, :columns, :special

  # Create the ReportTableCell object and initialize the attributes to some
  # default values. _line_ is the ReportTableLine this cell belongs to. _text_
  # is the text that should appear in the cell. _headerCell_ is a flag that
  # must be true only for table header cells.
  def initialize(line, text = '', headerCell = false)
    @line = line
    @line.addCell(self) if line

    @headerCell = headerCell
    # The printable form of the cell content
    @text = text
    # The original data of the cell content (optional, nil if not provided)
    @data = nil
    @category = nil
    @hidden = false
    # How to horizontally align the cell
    @alignment = :center
    # Horizontal padding between frame and cell content
    @padding = 3
    # Whether or not to indent the cell
    @indent = nil
    @fontSize = nil
    @bold = false
    @width = nil
    @rows = 1
    @columns = 1
    # Ignore everything and use this reference to generate the output.
    @special = nil
  end

  # Return true if two cells are similar enough so that they can be merged in
  # the report to a single, wider cell. _c_ is the cell to compare this cell
  # with.
  def ==(c)
    @text == c.text &&
    @alignment == c.alignment &&
    @padding == c.padding &&
    @indent == c.indent &&
    @category == c.category
  end

  # Turn the abstract cell representation into an HTML element tree.
  def to_html
    return nil if @hidden
    return @special.to_html if @special

    # Determine cell style
    alignSymbols = [ :left, :center, :right ]
    aligns = %w( left center right)
    style = "text-align:#{aligns[alignSymbols.index(@alignment)]}; "
    if @indent && @alignment != :center
      if @alignment == :left
        style += "padding-left:#{@padding + @indent * 8}px; " +
                 "padding-right:#{@padding}px; "
      elsif @alignment == :right
        style += "padding-left:#{@padding}px; " +
                 "padding-right:#{@padding +
                                  (@line.table.maxIndent - @indent) * 8}px; "
      end
    else
      style += "padding-left:#{@padding}px; padding-right:#{@padding}px; "
    end
    style += 'font-weight:bold; ' if @bold
    style += "font-size: #{@fontSize}px; " if fontSize

    attribs = { 'style' => style }
    # Determine cell attributes
    attribs['rowspan'] = "#{@rows}" if @rows > 1
    attribs['colspan'] = "#{@columns}" if @columns > 1
    attribs['class'] = @category ? @category : 'tabcell'

    cell = XMLElement.new('td', attribs)
    if @width
      cell << (div = XMLElement.new('div', 'style' => "width: #{@width}px"))
      div << XMLText.new(@text)
    else
      cell << XMLText.new(@text)
    end

    cell
  end

  # Add the text content of the cell to an Array of Arrays form of the table.
  def to_csv(csv)
    # We only support left indentation in CSV files as the spaces for right
    # indentation will be disregarded by most applications.
    indent = @indent && @alignment == :left ? '  ' * @indent : ''
    if @special
      csv[-1] << @special.to_csv
    elsif @data && @data.is_a?(String)
      csv[-1] << indent + @data
    elsif @text
      csv[-1] << indent + @text
    end
  end

end

