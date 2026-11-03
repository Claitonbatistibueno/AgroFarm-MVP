<?php
use PHPUnit\Framework\TestCase;

final class HelpersTest extends TestCase
{
    public function testEscapeNeutralisesHtml(): void
    {
        $this->assertSame('&lt;script&gt;alert(&#039;x&#039;)&lt;/script&gt;', e("<script>alert('x')</script>"));
        $this->assertSame('', e(null));
        $this->assertSame('42', e(42));
    }

    public function testValidDateAcceptsOnlyRealIsoDates(): void
    {
        $this->assertSame('2026-02-28', valid_date('2026-02-28', 'x'));
        $this->assertSame('x', valid_date('2026-02-30', 'x'));
        $this->assertSame('x', valid_date("2026-01-01' OR 1=1 --", 'x'));
        $this->assertSame('x', valid_date(['2026-01-01'], 'x'));
        $this->assertSame('x', valid_date(null, 'x'));
    }

    public function testEnvReturnsDefaultForMissingOrEmpty(): void
    {
        putenv('AGRO_TEST_EMPTY=');
        $this->assertSame('d', env('AGRO_TEST_MISSING_' . uniqid(), 'd'));
        $this->assertSame('d', env('AGRO_TEST_EMPTY', 'd'));
        putenv('AGRO_TEST_SET=value');
        $this->assertSame('value', env('AGRO_TEST_SET', 'd'));
    }

    public function testDotEnvLoaderDoesNotOverrideRealEnvironment(): void
    {
        $file = tempnam(sys_get_temp_dir(), 'env');
        file_put_contents($file, "# comment\nAGRO_A=from_file\nAGRO_B=\"quoted value\"\nAGRO_C=keep\nnot a pair\n");
        putenv('AGRO_C=from_env');
        farm_load_env($file);
        $this->assertSame('from_file', getenv('AGRO_A'));
        $this->assertSame('quoted value', getenv('AGRO_B'));
        $this->assertSame('from_env', getenv('AGRO_C'));
        unlink($file);
    }

    public function testCsrfTokenIsStableAndLong(): void
    {
        $_SESSION = [];
        $token = csrf_token();
        $this->assertSame(64, strlen($token));
        $this->assertSame($token, csrf_token());
        $this->assertStringContainsString($token, csrf_field());
    }

    public function testCsrfInjectionCoversFormsDeleteLinksAndFetch(): void
    {
        $_SESSION = ['csrf_token' => str_repeat('a', 64)];
        $html = '<html><head><title>t</title></head><body>'
              . '<form method="POST" action="x.php"></form>'
              . '<form method="get"></form>'
              . '<a href="?delete=7">del</a></body></html>';
        $out = farm_inject_csrf($html);

        $this->assertSame(1, substr_count($out, 'name="csrf_token"'), 'only POST forms get the hidden field');
        $this->assertStringContainsString('href="?delete=7&csrf_token=' . str_repeat('a', 64) . '"', $out);
        $this->assertStringContainsString('<meta name="csrf-token"', $out);
        $this->assertStringContainsString('X-CSRF-Token', $out);
    }

    public function testCsrfInjectionLeavesJsonAlone(): void
    {
        $json = '{"success":true}';
        $this->assertSame($json, farm_inject_csrf($json));
    }

    public function testSafeUploadRejectsUnsafeFiles(): void
    {
        $php = tempnam(sys_get_temp_dir(), 'up');
        file_put_contents($php, '<?php echo 1;');
        $file = ['name' => 'shell.php', 'tmp_name' => $php, 'size' => 13, 'error' => UPLOAD_ERR_OK];

        $this->assertNull(safe_upload($file, 'test', ['jpg', 'png']), 'php extension refused');
        $this->assertNull(safe_upload(['error' => UPLOAD_ERR_NO_FILE], 'test', ['jpg']), 'no file');
        $this->assertNull(safe_upload(['name' => 'a.jpg', 'tmp_name' => $php, 'size' => 0, 'error' => 0], 'test', ['jpg']), 'empty');
        $this->assertNull(safe_upload(['name' => 'a.jpg', 'tmp_name' => $php, 'size' => 9e9, 'error' => 0], 'test', ['jpg']), 'too big');
        // not created by an HTTP upload -> refused even with a good extension
        $this->assertNull(safe_upload(['name' => 'a.png', 'tmp_name' => $php, 'size' => 13, 'error' => 0], 'test', ['png']));
        unlink($php);
    }
}
