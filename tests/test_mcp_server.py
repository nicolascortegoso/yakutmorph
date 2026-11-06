import json
import shutil
import sys
import unittest

try:
    import anyio
    from mcp.client.client import Client
    from mcp.client.stdio import StdioServerParameters

    from yakutmorph.mcp_server import server
    HAVE_MCP = True
except ImportError:  # the optional dependency is not installed
    HAVE_MCP = False


def call(client_target, tool, arguments):
    """Calls one tool through a real MCP client and returns its result."""
    async def run():
        async with Client(client_target) as client:
            return await client.call_tool(tool, arguments)
    return anyio.run(run)


def structured(result):
    if result.structured_content is not None:
        return result.structured_content
    return json.loads(result.content[0].text)


@unittest.skipUnless(HAVE_MCP, 'needs the optional dependency: pip install "yakutmorph[mcp]"')
class TestMCPServer(unittest.TestCase):

    def test_lists_all_tools_as_read_only(self):
        async def run():
            async with Client(server) as client:
                return (await client.list_tools()).tools
        tools = {tool.name: tool for tool in anyio.run(run)}
        self.assertEqual(set(tools), {
            'analyze_text', 'analyze_word', 'to_conllu', 'explain_tags', 'list_tags', 'generate_word_form',
            'find_examples',
        })
        for tool in tools.values():
            self.assertTrue(tool.annotations.read_only_hint, tool.name)

    def test_analyze_text(self):
        result = structured(call(server, 'analyze_text', {'text': 'мин кини дьиэтин көрдүм.'}))
        tokens = result['tokens']
        self.assertEqual([t['text'] for t in tokens], ['мин', 'кини', 'дьиэтин', 'көрдүм', '.'])
        house = tokens[2]
        self.assertEqual(house['analysis'], 'дьиэ+N+POSS.3SG.ACC')
        self.assertEqual((house['lemma'], house['upos'], house['transducer']), ('дьиэ', 'NOUN', 'voc'))
        self.assertIn('Case=Acc', house['features'].split('|'))
        self.assertNotIn('analysis', tokens[4])  # punctuation has no analysis

    def test_ambiguous_word_lists_alternatives(self):
        tokens = structured(call(server, 'analyze_text', {'text': 'мин аатым Кэскил.'}))['tokens']
        self.assertTrue(tokens[0]['ambiguous'])
        self.assertNotIn(tokens[0]['analysis'], tokens[0]['alternatives'])

    def test_analyze_word(self):
        result = structured(call(server, 'analyze_word', {'word': 'дьиэтин'}))
        self.assertIn('дьиэ+N+POSS.3SG.ACC', result['analyses'])
        self.assertEqual(result['transducer'], 'voc')

    def test_to_conllu(self):
        result = call(server, 'to_conllu', {'text': 'мин аатым Кэскил.'})
        conllu = result.content[0].text
        self.assertTrue(conllu.startswith('# text = мин аатым Кэскил.'))
        self.assertEqual(len(conllu.split('\n')), 5)

    def test_explain_tags(self):
        tags = structured(call(server, 'explain_tags', {'tags': ['POSS.3SG.ACC', '+NOT_A_TAG']}))['tags']
        self.assertEqual(tags['+POSS.3SG.ACC']['ud']['Case'], 'Acc')
        self.assertIsNone(tags['+NOT_A_TAG'])

    def test_generate_word_form(self):
        result = structured(call(server, 'generate_word_form', {'analysis': 'дьиэ+N+POSS.1SG.DAT'}))
        self.assertEqual(result['forms'], ['дьиэбэр'])

    def test_find_examples(self):
        result = structured(call(server, 'find_examples', {'root': 'дьиэ', 'tag': 'POSS.3SG.ACC', 'limit': 2}))
        self.assertGreater(result['total'], 0)
        self.assertLessEqual(len(result['examples']), 2)
        example = result['examples'][0]
        self.assertEqual(example['match']['analysis'].split('+')[0], 'дьиэ')
        self.assertIsInstance(example['page'], str)

    def test_find_examples_returns_three_by_default(self):
        result = structured(call(server, 'find_examples', {'tag': 'REFL/PASS'}))
        self.assertEqual(len(result['examples']), 3)
        result = structured(call(server, 'find_examples', {'tag': 'REFL/PASS', 'limit': 5}))
        self.assertEqual(len(result['examples']), 5)

    def test_find_examples_without_criteria_is_an_error(self):
        self.assertTrue(call(server, 'find_examples', {}).is_error)

    @unittest.skipUnless(shutil.which('yakutmorph-mcp') or sys.executable, 'no Python executable')
    def test_runs_over_stdio(self):
        """Starts the server as a separate process, as an MCP client would."""
        params = StdioServerParameters(command=sys.executable, args=['-m', 'yakutmorph.mcp_server'])
        result = structured(call(params, 'analyze_word', {'word': 'дьиэтин'}))
        self.assertIn('дьиэ+N+POSS.3SG.ACC', result['analyses'])


if __name__ == '__main__':
    unittest.main()
