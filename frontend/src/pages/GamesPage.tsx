import LibraryPage from "../components/LibraryPage";

export default function GamesPage() {
  return (
    <LibraryPage
      category="games"
      title="Oyunlarım"
      completedLabel="Tamamlananlar"
      wishlistLabel="İstek Listesi"
    />
  );
}
