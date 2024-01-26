#!/usr/bin/env python

from datetime import datetime
import re
import xml.etree.ElementTree as ET
import zipfile
from gi.repository import GObject, Nautilus, Gio
from urllib.parse import unquote

META_NS={'dc': 'http://purl.org/dc/elements/1.1/'}

LANGUAGES={
    'en': 'English / English',
    'es': 'Spanish / Español',
    'fr': 'French / Français',
    'de': 'German / Deutsch',
    'zh-Hans': 'Chinese (Simplified) / 中文（简体）',
    'zh-Hant': 'Chinese (Traditional) / 中文（繁體）',
    'ja': 'Japanese / 日本語',
    'ko': 'Korean / 한국어',
    'ru': 'Russian / Русский',
    'ar': 'Arabic / العربية',
    'pt': 'Portuguese / Português',
    'it': 'Italian / Italiano',
    'nl': 'Dutch / Nederlands',
    'sv': 'Swedish / Svenska',
    'no': 'Norwegian / Norsk',
    'da': 'Danish / Dansk',
    'fi': 'Finnish / Suomi',
    'el': 'Greek / Ελληνικά',
    'he': 'Hebrew / עברית',
    'hi': 'Hindi / हिन्दी',
    'id': 'Indonesian / Bahasa Indonesia',
    'tr': 'Turkish / Türkçe',
    'th': 'Thai / ไทย',
    'vi': 'Vietnamese / Tiếng Việt',
    'pl': 'Polish / Polski',
    'cs': 'Czech / Čeština',
    'hu': 'Hungarian / Magyar',
    'ro': 'Romanian / Română',
    'bg': 'Bulgarian / Български',
    'ca': 'Catalan / Català',
    'hr': 'Croatian / Hrvatski',
    'sk': 'Slovak / Slovenčina',
    'sl': 'Slovenian / Slovenščina',
    'sr': 'Serbian / Српски',
    'mk': 'Macedonian / Македонски',
    'sq': 'Albanian / Shqip',
    'et': 'Estonian / Eesti',
    'lv': 'Latvian / Latviešu',
    'lt': 'Lithuanian / Lietuvių',
    'mt': 'Maltese / Malti',
    'gd': 'Gaelic / Gàidhlig',
    'cy': 'Welsh / Cymraeg',
    'ga': 'Irish / Gaeilge',
    'eu': 'Basque / Euskara',
    'eo': 'Esperanto / Esperanto',
    'la': 'Latin / Latina',
}


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
        metadata, title, authors = self._get_meta_from_epub(filepath)

        section = Gio.ListStore.new(item_type=Nautilus.PropertiesItem)
        if title is None:
            title = "EPUB Metadata"
        if authors is None:
            title = title
        else:
            title = f"{title} by {authors}"

        for val in metadata:
            section.append(
                    Nautilus.PropertiesItem(
                        name= val[1],
                        value= val[0]
                        )
                    )

        return [
                Nautilus.PropertiesModel(
                    title = title,
                    model = section
                    )
                ]

    @classmethod
    def _sanitize_html(cls, str: str) -> str:
        if str is None:
            return None
        headings = re.compile('<h[1-6][^>]*>(.*?)</h[1-6]>')
        paragraphs = re.compile('</p>')
        str = re.sub(headings, '\n', str)
        str = re.sub(paragraphs, '\n', str)
        tags = re.compile("<.*?>")
        return re.sub(tags, '', str)


    @classmethod
    def _safely_get_prop(cls, meta, name: str) -> list:
        match = meta.find(name, namespaces=META_NS)
        if match is None:
            return (False, None)
        else:
            return (True, match.text)


    def _get_meta_from_epub(self, path: str) -> list[tuple]:
        entries = []


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

        title = self._safely_get_prop(metadata, './/dc:title')
        if title[0]:
            entries.append((title[1], "Title"))
            booktitle = title[1]
        else: 
            booktitle = None

        description = self._safely_get_prop(metadata, './/dc:description')
        if description[0]:
            entries.append((self._sanitize_html(description[1]), "Description"))

        identifiers = metadata.findall('.//dc:identifier', namespaces=META_NS)
        for identifier in identifiers:
            scheme =  identifier.attrib.get("{http://www.idpf.org/2007/opf}scheme")
            if scheme and scheme == "ISBN":
                entries.append((identifier.text, "ISBN"))

        creator = self._safely_get_prop(metadata, './/dc:creator')
        if creator[0]:
            creator_arr = creator[1].strip().split(';')
            if len(creator_arr) >= 3:
                first, *middle, last = creator_arr
                middle_txt = ', '.join(middle)
                author_format = f"{first}, {middle_txt} and {last}"
            elif len(creator_arr) == 2:
                author_format = f"{creator_arr[0]} and {creator_arr[1]}"
            else:
                author_format = creator_arr[0]
            title = "Author" if len(creator_arr) == 1 else "Authors"
            entries.append((author_format, title))

        publisher = self._safely_get_prop(metadata, './/dc:publisher')
        if publisher[0]:
            entries.append((publisher[1], "Publisher"))

        language = self._safely_get_prop(metadata, './/dc:language')
        if language[0]:
            entries.append((LANGUAGES[language[1]], "Language"))

        date = self._safely_get_prop(metadata, './/dc:date')
        if date[0]:
            fdate = datetime.strftime(datetime.strptime(date[1], "%Y-%m-%dT%H:%M:%S%z"), "%Y/%m/%d")
            entries.append((fdate, "Creation Date"))

        genres = [subject.text for subject in metadata.findall('.//dc:subject', namespaces=META_NS)]
        if len(genres) > 0:
            title = "Genre" if len(genres) == 1 else "Genres"
            genre_str = ', '.join(genres)
            entries.append((genre_str, title))

        return (entries, booktitle, author_format)


