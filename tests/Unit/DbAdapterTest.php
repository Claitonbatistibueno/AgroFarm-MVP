<?php
use PHPUnit\Framework\TestCase;

/** The mysqli-style adapter (lib/db.php) on an in-memory SQLite database. */
final class DbAdapterTest extends TestCase
{
    private FarmDb $db;

    protected function setUp(): void
    {
        $pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $pdo->exec('CREATE TABLE animal (animal_id INTEGER PRIMARY KEY, tag TEXT, weight REAL, lot INTEGER)');
        $pdo->exec("INSERT INTO animal (tag, weight, lot) VALUES ('IE 1', 500.5, 1), ('IE 2', 610, 1), ('IE 3', 420, NULL)");
        $this->db = new FarmDb($pdo);
    }

    public function testBindParamReadsVariablesAtExecuteTime(): void
    {
        $stmt = $this->db->prepare('SELECT tag FROM animal WHERE animal_id = ?');
        $id = 1;
        $stmt->bind_param('i', $id);
        $id = 2;                       // mysqli binds by reference
        $stmt->execute();
        $this->assertSame('IE 2', $stmt->get_result()->fetch_assoc()['tag']);
    }

    public function testTypeLettersCastValues(): void
    {
        $stmt = $this->db->prepare('SELECT COUNT(*) AS c FROM animal WHERE animal_id = ?');
        $id = '1 OR 1=1';              // 'i' casts to int 1, so no injection
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $this->assertSame(1, (int) $stmt->get_result()->fetch_assoc()['c']);
    }

    public function testNullStaysNull(): void
    {
        $stmt = $this->db->prepare('INSERT INTO animal (tag, weight, lot) VALUES (?, ?, ?)');
        $tag = 'IE 4'; $w = 300.0; $lot = null;
        $stmt->bind_param('sdi', $tag, $w, $lot);
        $this->assertTrue($stmt->execute());
        $row = $this->db->query("SELECT lot FROM animal WHERE tag = 'IE 4'")->fetch_assoc();
        $this->assertNull($row['lot']);
    }

    public function testExecuteWithArrayWorksLikePdo(): void
    {
        $stmt = $this->db->prepare('SELECT tag FROM animal WHERE lot = ? ORDER BY animal_id');
        $stmt->execute([1]);
        $this->assertSame(2, $stmt->num_rows);
        $this->assertSame(['IE 1', 'IE 2'], array_column($stmt->get_result()->fetch_all(), 'tag'));
    }

    public function testResultSupportsSeekRowsAndForeach(): void
    {
        $res = $this->db->query('SELECT tag FROM animal ORDER BY animal_id');
        $this->assertSame(3, $res->num_rows);
        $this->assertSame(['IE 1'], $res->fetch_row());
        $res->data_seek(0);
        $this->assertSame('IE 1', $res->fetch_assoc()['tag']);
        $tags = [];
        foreach ($res as $row) { $tags[] = $row['tag']; }
        $this->assertSame(['IE 1', 'IE 2', 'IE 3'], $tags);
        $this->assertCount(3, $res);
    }

    public function testFetchReturnsNullAtTheEnd(): void
    {
        $res = $this->db->query('SELECT tag FROM animal WHERE animal_id = 1');
        $this->assertNotNull($res->fetch_assoc());
        $this->assertNull($res->fetch_assoc());
    }

    public function testNonSelectQueryReturnsTrueAndAffectedRows(): void
    {
        $this->assertTrue($this->db->query("UPDATE animal SET lot = 2 WHERE lot = 1"));
        $stmt = $this->db->prepare('DELETE FROM animal WHERE lot = ?');
        $lot = 2;
        $stmt->bind_param('i', $lot);
        $stmt->execute();
        $this->assertSame(2, $stmt->affected_rows);
    }

    public function testTransactions(): void
    {
        $this->db->begin_transaction();
        $this->db->query("DELETE FROM animal");
        $this->db->rollback();
        $this->assertSame(3, $this->db->query('SELECT COUNT(*) AS c FROM animal')->fetch_assoc()['c']);
    }
}
