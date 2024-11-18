#!/usr/bin/env python

from urllib.parse import unquote
from gi.repository import GObject, Nautilus, Gio
from elftools.elf.elffile import ELFFile

# enums from here: https://github.com/eliben/pyelftools/blob/main/elftools/elf/enums.py
ARCHITECTURES = {
    "EM_NONE": "No Architecture",
    "EM_386": "Intel i386 / x86",
    "EM_SPARC": "Sun SPARC",
    "EM_68K": "Motorola 68000",
    "EM_MIPS": "MIPS",
    "EM_PARISC": "Hewlett & Packard PA-RISC",
    "EM_PPC": "32-bit PowerPC",
    "EM_PPC64": "64-bit PowerPC",
    "EM_S390": "IBM System/390",
    "EM_ARM": "32-bit ARM / aarch32",
    "EM_ALPHA": "Digital Equipment Corporation Alpha",
    "EM_SH": "Hitachi SuperH",
    "EM_SPARCV9": "Sun SPARC Version 9",
    "EM_X86_64": "x86_64 / amd64",
    "EM_PDP11": "Digital Equipment Corporation PDP-11",
    "EM_AARCH64": "64-bit ARM / aarch64",
}
ABIS = {
    "ELFOSABI_SYSV": "UNIX System V",
    "ELFOSABI_HPUX": "Hewlett & Packard UNIX",
    "ELFOSABI_NETBSD": "NetBSD",
    "ELFOSABI_LINUX": "Linux",
    "ELFOSABI_HURD": "GNU/HURD",
    "ELFOSABI_SOLARIS": "Sun Solaris",
    "ELFOSABI_AIX": "IBM AIX",
    "ELFOSABI_IRIX": "Silicon Graphics IRIX",
    "ELFOSABI_FREEBSD": "FreeBSD",
    "ELFOSABI_OPENBSD": "OpenBSD",
}
TYPES = {
    "ET_NONE": "None",
    "ET_REL": "Relocatable Object File",
    "ET_EXEC": "Executable Program",
    "ET_DYN": "Dynamically Linkable Object File",
    "ET_CORE": "Core / Crash Dump",
}


MIMETYPES = (
    "application/x-pie-executable",
    "application/x-sharedlib",
    "application/x-elf",
    "application/x-executable",
)


class ElfInformationPage(GObject.GObject, Nautilus.PropertiesModelProvider):
    def get_models(
        self, files: list[Nautilus.FileInfo]
    ) -> list[Nautilus.PropertiesModel]:
        if len(files) != 1:
            return []

        file = files[0]

        if file.is_directory():
            return []

        mimetype = file.get_mime_type()

        if mimetype not in MIMETYPES:
            return []
        filepath = unquote(file.get_uri()[7:])

        metadata = self._parse_elf(filepath)

        section = Gio.ListStore.new(item_type=Nautilus.PropertiesItem)
        for row in metadata:
            section.append(Nautilus.PropertiesItem(name=row[1], value=row[0]))
        return [
            Nautilus.PropertiesModel(
                title="Executable and linkable file", model=section
            )
        ]

    def _parse_elf(self, file: str) -> list[tuple]:
        entries = []
        with open(file, "rb") as file:
            elf = ELFFile(file)
            header = elf.header

            type = header["e_type"]
            entries.append((TYPES.get(type, type), "ELF File Type"))

            architecure = header["e_machine"]
            entries.append(
                (ARCHITECTURES.get(architecure, architecure), "Architecture")
            )

            entry_point = header["e_entry"]
            if entry_point != 0:
                entries.append((hex(entry_point), "Entry Point Address"))
            else:
                entries.append(("None", "Entry Point Address"))

            abi = header["e_ident"]["EI_OSABI"]
            entries.append((ABIS.get(abi, abi), "Application Binary Interface"))
        return entries
