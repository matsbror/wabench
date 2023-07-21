/*
 * Copyright (C) 2005-2017 Apple Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

#define NDEBUG 1

#include <stdio.h>
#include <timestamps.h>

int main(int argc, char** argv)
{
    char buffer[26];
    timestamp_t millisec = timestamp();

    print_timestamp(stdout, "calibrate\0", millisec);

    timeduration_t elapsed = time_since(millisec);

    print_elapsed_time(stdout, "calibrate\0", elapsed);

    return 0;
}
