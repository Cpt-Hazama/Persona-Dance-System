PD = PD or {}
PD.MNS = PD.MNS or {}

PD.MNS.Difficulty = {
    [0] = "Easy",
    [1] = "Normal",
    [2] = "Hard",
    [3] = "All Night"
}
PD.MNS.NoteDown = 0
PD.MNS.NoteCross = 1
PD.MNS.NoteLeft = 2
PD.MNS.NoteCircle = 3
PD.MNS.NoteUp = 4
PD.MNS.NoteTriangle = 5
PD.MNS.NoteScratch = 8

/*
    Header
        Offset	Type	Description
        0x00	U32	Magic (MNS_)
        0x04	U32	Always 0
        0x08	U32	Always 1
        0x0C	U32	Music ID - same value affixed to filename
        0x10	F32	Tempo in BPM. Note that this won't affect the BPM in the song selection menu.
        0x16	U16	Song difficulty. 00-Easy, 01-Normal, 02-Hard, 03-All Night
        0x1C	U32	Number of notes in the file in little endian. Does not include duplicate notes.
        0x20	u32	Always 0

    Note Data
        Note data are in groups of 8 bytes located directly after the header.
        Offset	Description
        0x00	Which beat of a fourth note to place the note onto.
        0x01	If the note takes place on the second eighth note of the beat, then this value is 0x80.
        0x02	Measure this beat takes place on
        0x03	Always 0.
        0x04	Note Location
        0x05	Hold Timer
        0x06	Note Metadata. 01 if Fever Scratch, 02 if P3D/P5D Double Note.
        0x07	Always 0.

    Note Location
    Offset 0x04 in the note's data which determines where on the screen a note should be. Note that values 06 and 07 are unused, which could suggest that Right and Square could have originally been possible note locations.
        Value	Location
        00	Down
        01	Cross
        02	Left
        03	Circle
        04	Up
        05	Triangle
        08	Scratch
*/

local filePath = "data/persona_dance/"
local Easy, Normal, Hard, AllNight = 0, 1, 2, 3
function parseMNS(gameID,musicID,difficulty)
    local data = {}
    local f = file.Open(filePath .. "/" .. gameID .. "/mns" .. musicID .. "_" .. difficulty .. ".bin", "rb", "THIRDPARTY")
        if !f then
            print("MNS file could not be found or opened!")
            return
        end
        local header = f:Read(4)
        if header != "MNS\x00" then
            print("Invalid file header!")
            return
        end

        f:Seek(0x0C)
        local musicID = f:ReadLong()
        print("Music ID (0x0C): " .. musicID)

        f:Seek(0x10)
        local tempo = f:ReadFloat()
        print("Tempo (0x10): " .. tempo)

        f:Seek(0x16)
        local difficulty = f:ReadShort()
        print("Difficulty (0x16): " .. PD.MNS.Difficulty[difficulty])

        f:Seek(0x1C)
        local noteCount = f:ReadLong()
        print("Note Count (0x1C): " .. noteCount)

        local noteOffset = 0x24
        f:Seek(noteOffset)
        for i = 1, noteCount do
            local beat = f:ReadByte()
            local eighthNote = f:ReadByte() == 0x80
            local measure = f:ReadByte()
            f:ReadByte()
            local location = f:ReadByte()
            local holdTimer = f:ReadByte()
            local metadata = f:ReadByte()
            f:ReadByte()
        
            local absolute_beats = (measure *4) +beat
            local note_time = absolute_beats *(60 /tempo)
            if eighthNote then
                note_time = note_time +((60 /tempo) /2)
            end
        
            table.insert(data, {
                beat = beat,
                eighthNote = eighthNote,
                measure = measure,
                location = location,
                holdTimer = holdTimer,
                metadata = metadata,
                time = note_time -- Is this correct?
            })
        end
    f:Close()

    -- file.Write("mns.json", util.TableToJSON(data)) -- Testing
    
    return data
end

parseMNS("p4d", "001", Normal)