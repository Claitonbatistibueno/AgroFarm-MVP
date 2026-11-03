<?php
use PHPUnit\Framework\TestCase;

final class VetAiTest extends TestCase
{
    public function testParsesJsonWrappedInMarkdownFence(): void
    {
        $text = "```json\n{\"summary\":\"ok\",\"confidence\":\"High\"}\n```";
        $this->assertSame(['summary' => 'ok', 'confidence' => 'High'], vet_ai_parse_json($text));
    }

    public function testParsesJsonWithSurroundingText(): void
    {
        $this->assertSame(['a' => 1], vet_ai_parse_json('Here you go: {"a":1} hope it helps'));
    }

    public function testReturnsNullWhenThereIsNoJson(): void
    {
        $this->assertNull(vet_ai_parse_json('Sorry, I cannot help with that.'));
        $this->assertNull(vet_ai_parse_json('{not json}'));
    }

    public function testNormaliseClampsAndCleansTheReport(): void
    {
        $r = vet_ai_normalise([
            'summary'    => 'Lameness',
            'hypotheses' => [['name' => 'Foot rot', 'prob' => 140], ['name' => '', 'prob' => 10], ['prob' => 5], 'bad', ['name' => 'DD', 'prob' => -3]],
            'questions'  => ['Odour?', '', 7],
            'warnings'   => 'not a list',
            'confidence' => 'MEDIUM',
        ]);
        $this->assertSame([['name' => 'Foot rot', 'prob' => 100], ['name' => 'DD', 'prob' => 0]], $r['hypotheses']);
        $this->assertSame(['Odour?', '7'], $r['questions']);
        $this->assertSame([], $r['warnings']);
        $this->assertSame('Medium', $r['confidence']);
        $this->assertSame('', $r['justification']);
    }

    public function testUnknownConfidenceFallsBackToLow(): void
    {
        $this->assertSame('Low', vet_ai_normalise(['confidence' => 'certain'])['confidence']);
    }

    public function testAnalyseWithoutApiKeyExplainsTheSetup(): void
    {
        putenv('ANTHROPIC_API_KEY=');
        $db = new FarmDb(new PDO('sqlite::memory:'));
        $out = vet_ai_analyse($db, 1, 39.0, [], '');
        $this->assertArrayHasKey('error', $out);
        $this->assertStringContainsString('ANTHROPIC_API_KEY', $out['error']);
    }
}
