package br.com.sigas.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.entities.Produtos;
import br.com.sigas.repositories.ProdutosRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

@Service
public class ProdutosService {

    @Autowired
    private ProdutosRepository produtosRepository;

    @Transactional
    public void criarProduto(Produtos produto) {
        produtosRepository.inserirProduto(
                produto.getNome_produto(),
                produto.getDescricao(),
                produto.getUnidade(),
                produto.getPreco_unidade(),
                produto.getQtd_estoque(),
                produto.getCategoria().getId_categoria());
    }

    public Produtos buscarProdutoPorId(Long id) {
        return produtosRepository.buscarProdutoPorId(id)
                .orElseThrow(() -> new EntityNotFoundException("Produto não encontrado"));
    }

    public List<Produtos> buscarProdutoPorNome(String nomeProduto) {
        return produtosRepository.buscarProdutoPorNome(nomeProduto);
    }

    public List<Produtos> buscarProdutosPorCategoria(Long idCategoria) {
        return produtosRepository.buscarProdutosPorCategoria(idCategoria);
    }

    @Transactional
    public void atualizarProduto(Long id, Produtos produtoAtualizado) {
        produtosRepository.atualizarProduto(
                id,
                produtoAtualizado.getNome_produto(),
                produtoAtualizado.getDescricao(),
                produtoAtualizado.getUnidade(),
                produtoAtualizado.getPreco_unidade(),
                produtoAtualizado.getQtd_estoque());
    }

    @Transactional
    public void deletarProduto(Long id) {
        produtosRepository.deletarProduto(id);
    }
}
