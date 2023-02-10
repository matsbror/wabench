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

#include <sys/time.h>
#include <time.h>
#include <stdio.h>

int main(int argc, char** argv)
{
    char buffer[26];
    int millisec;
    struct tm* tm_info;
    struct timeval tv;
    gettimeofday(&tv, NULL);

    millisec = tv.tv_usec/1000.0; // Round to nearest millisec
    if (millisec>=1000) { // Allow for rounding up to nearest second
        millisec -=1000;
        tv.tv_sec++;
    }

    tm_info = localtime(&tv.tv_sec);

    strftime(buffer, 26, "%Y:%m:%d %H:%M:%S", tm_info);
    //printf("%s.%03d\n", buffer, millisec);

    return 0;
}
