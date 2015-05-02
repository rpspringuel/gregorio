/*
 * Copyright (C) 2008-2015 The Gregorio Project (see CONTRIBUTORS.md)
 *
 * This file is part of Gregorio.
 *
 * Gregorio is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Gregorio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Gregorio.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef CHARACTERS_H
#define CHARACTERS_H

#include <stdbool.h>
#include "struct.h"

/*
 * 
 * The three next defines are the possible values of center_is_determined.
 * 
 * CENTER_NOT_DETERMINED means that the plugin has encountered no { nor } (in
 * the gabc syntax). CENTER_HALF_DETERMINED means that the plugin has
 * encountered a { but no }, and we will try to determine a middle starting
 * after the {. CENTER_FULLY_DETERMINED means that lex has encountered a { and
 * a }, so we won't determine the middle, it is considered done.
 * CENTER_DETERMINING_MIDDLE is used internally in the big function to know
 * where we are in the middle determination.
 * 
 */

typedef enum gregorio_center_determination {
    CENTER_NOT_DETERMINED = 0,
    CENTER_HALF_DETERMINED,
    CENTER_FULLY_DETERMINED,
    CENTER_DETERMINING_MIDDLE,
} gregorio_center_determination;

// this is a temporary structure that will be used for style determination

typedef struct det_style {
    unsigned char style;
    struct det_style *previous_style;
    struct det_style *next_style;
} det_style;

gregorio_character *gregorio_first_text(gregorio_score *score);

void gregorio_write_text(bool skip_initial,
        gregorio_character *current_character,
        FILE *f, void (*printverb) (FILE *, grewchar *),
        void (*printchar) (FILE *, grewchar),
        void (*begin) (FILE *, grestyle_style),
        void (*end) (FILE *, grestyle_style),
        void (*printspchar) (FILE *, grewchar *));

void gregorio_write_initial(gregorio_character *current_character,
        FILE *f, void (*printverb) (FILE *, grewchar *),
        void (*printchar) (FILE *, grewchar),
        void (*begin) (FILE *, grestyle_style),
        void (*end) (FILE *, grestyle_style),
        void (*printspchar) (FILE *, grewchar *));

gregorio_character *gregorio_first_text(gregorio_score *score);

void gregorio_rebuild_characters(gregorio_character **param_character,
        gregorio_center_determination center_is_determined,
        gregorio_lyric_centering centering_scheme, bool skip_initial);

void gregorio_rebuild_first_syllable(gregorio_character **param_character,
        bool separate_initial);

#endif