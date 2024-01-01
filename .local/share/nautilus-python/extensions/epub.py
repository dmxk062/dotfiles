#!/usr/bin/env python

from datetime import datetime
import re
import xml.etree.ElementTree as ET
import zipfile
from gi.repository import GObject, Nautilus, Gio
from urllib.parse import unquote

META_NS={'dc': 'http://purl.org/dc/elements/1.1/'}

class EpubInformationPage(GObject.GObject, Nautilus.PropertiesModelProvider):
    def get_models(self,
                   files: list[Nautilus.FileInfo]
                   ) -> list[Nautilus.PropertiesModel]:
        if len(files) != 1:
            return []
        
        file = files[0]

        if file.is_directory():
            return []

        if file.get_mime_type() != "application/epub+zip":
            return []


        filepath = unquote(file.get_uri()[7:])
        metadata = self._get_meta_from_epub(filepath)

        section = Gio.ListStore.new(item_type=Nautilus.PropertiesItem)
        for item in [
                    Nautilus.PropertiesItem(
                        name = "Title",
                        value = metadata["title"]
                    ),
                    Nautilus.PropertiesItem(
                        name = "Author" if len(metadata["creators"]) == 1 else "Authors",
                        value = ', '.join(metadata["creators"])
                    ),
                    Nautilus.PropertiesItem(
                        name = "Published",
                        value = datetime.strftime(datetime.strptime(metadata["date"], "%Y-%m-%dT%H:%M:%S%z"), "%Y/%m/%d")
                    ),
                    Nautilus.PropertiesItem(
                        name = "ISBN",
                        value = metadata["isbn"]
                    ),
                    Nautilus.PropertiesItem(
                        name = "Language",
                        value = metadata["language"]
                    ),
                    Nautilus.PropertiesItem(
                        name = "Genres",
                        value = ', '. join(metadata["genres"])
                    ),
                    Nautilus.PropertiesItem(
                        name = "Description",
                        value = metadata["description"]
                    )
                ]:
            section.append(item)

        return [
                Nautilus.PropertiesModel(
                    title = "Epub Metadata",
                    model = section
                    )
                ]

    @classmethod
    def _sanitize_html(cls, str: str) -> str:
        tags = re.compile("<.*?>")
        return re.sub(tags, ' ', str)


    def _get_meta_from_epub(self, path: str) -> dict[str or list[str]]:
        with zipfile.ZipFile(path, "r") as file:
            with file.open('META-INF/container.xml') as meta_xml:
                metastr = meta_xml.read()
            
            metaroot = ET.fromstring(metastr)
            metapath = metaroot.find(
                    './/{urn:oasis:names:tc:opendocument:xmlns:container}rootfile'
                    ).get('full-path')
            with file.open(metapath) as metafile:
                content = metafile.read()

            metadata = ET.fromstring(content)
            isbn = None
            identifiers = metadata.findall('.//dc:identifier', namespaces=META_NS)
            for identifier in identifiers:
                scheme =  identifier.attrib.get("{http://www.idpf.org/2007/opf}scheme")
                if scheme and scheme == "ISBN":
                    isbn = identifier.text

            return {
                'publisher': metadata.find('.//dc:publisher', namespaces=META_NS).text,
                'description': self._sanitize_html(metadata.find('.//dc:description', namespaces=META_NS).text),
                'language': metadata.find('.//dc:language', namespaces=META_NS).text,
                'creators': metadata.find('.//dc:creator', namespaces=META_NS).text.strip().split(";"),
                'title': metadata.find('.//dc:title', namespaces=META_NS).text,
                'date': metadata.find('.//dc:date', namespaces=META_NS).text,
                'genres': [subject.text for subject in metadata.findall('.//dc:subject', namespaces=META_NS)],
                'isbn': isbn
                    }
