import unittest
from yakutmorph.transducers import YakutTransducer

import os


class TestYakutAnalyzer(unittest.TestCase):
    def setUp(self):
        self.this_dir = os.path.dirname(__file__)
        self.coverage_threshold = 0.70
        self.base_folder = 'analyses'
        self.test_files = dict()
        with open(os.path.join(self.this_dir, 'testing_data_index.csv'), 'r', encoding='utf-8') as file:
            lines = file.readlines()[1:]
            for line in lines:
                filename, content, sources = line.split('\t')
                self.test_files[filename] = {'content': content, 'sources': sources}
        self.transducer = YakutTransducer()

    def update_readme_file(self, table):
        with open(os.path.join(self.this_dir, 'templates/analysis.stub')) as f:
            readme_stub = f.read()
        readme = readme_stub.replace('{TABLE}', '\n'.join(table))

        with open('analysis.md', 'w') as f:
            f.write(readme)

    def write_failed_report(self, total_failed_analyses):
        columns = ('filename', 'row', 'surface', 'stem', 'surface_gloss', 'stem_gloss', 'analysis', 'page', 'section', 'notes')
        with open(os.path.join(self.this_dir,'results/failed_analyses.csv'), 'w') as file:
            header = '\t'.join(columns)
            file.write(header)
            for failed_analysis in total_failed_analyses:
                row = '\t'.join(failed_analysis)
                file.write(f'\n{row}')

    def write_coverage_report(self, coverage):
        percentages = list()
        total_samples = 0
        columns = ('filename', 'content', 'samples', 'accuracy', 'sources')
        table_content = list()
        header = '|' + '|'.join(columns) + '|'
        line_separator = '|:---:' * len(columns) + '|'
        table_content.append(header)
        table_content.append(line_separator)
        for filename, description in coverage.items():

            total_samples += description[1]
            percentages.append(description[2])

            content = description[0]
            n_samples = str(description[1])
            percentage = description[2] * 100
            sources = description[3]
            row = f'| {filename} | {content} | {n_samples} | {percentage:.2f}% | {sources} |'
            table_content.append(row)

        average = sum(percentages) / len(percentages)

        total = f'| TOTAL |  | {total_samples} | {average * 100:.2f}% |  |'
        table_content.append(total)

        self.update_readme_file(table_content)

        return average

    @unittest.skipUnless(
        os.path.isdir(os.path.join(os.path.dirname(__file__), 'analyses')),
        'test data folder tests/analyses/ is not available'
    )
    def test_coverage(self):
        coverage = {}
        total_failed_analyses = []
        for filename, description in self.test_files.items():
            n_rows = 0
            failed_analyses = []
            with open(os.path.join(self.this_dir, self.base_folder, filename), 'r', encoding='utf-8') as file:
                # Read columns by header name: some files carry extra
                # columns (e.g. 'transducer' in annotated_corpus.csv).
                columns = file.readline().rstrip('\n').split('\t')
                for line in file:
                    n_rows += 1
                    row = dict(zip(columns, line.rstrip('\n').split('\t')))
                    surface, stem, analysis = row['surface'], row['stem'], row['analysis']
                    surface_gloss, stem_gloss = row.get('surface_gloss', ''), row.get('stem_gloss', '')
                    page, section, notes = row.get('page', ''), row.get('section', ''), row.get('notes', '')
                    if analysis not in self.transducer.analyse(surface):
                        row = (filename, str(n_rows + 1), surface, stem, surface_gloss, stem_gloss, analysis, page, section, notes)
                        failed_analyses.append(row)
            percentage = (n_rows - len(failed_analyses)) / n_rows
            coverage[filename] = description['content'], n_rows, percentage, description['sources']
            total_failed_analyses.extend(failed_analyses)

        self.write_failed_report(total_failed_analyses)

        average = self.write_coverage_report(coverage)

        self.assertGreater(average, self.coverage_threshold)


if __name__ == '__main__':
    unittest.main()
