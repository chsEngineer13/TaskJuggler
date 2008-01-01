#
# TjException.rb - The TaskJuggler III Project Management Software
#
# Copyright (c) 2006, 2007, 2008 by Chris Schlaeger <cs@kde.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#


class TjException < RuntimeError

  attr_reader :error, :fatal

  def initialize(error = true, fatal = false)
    @error = error
    @fatal = fatal
  end

end

